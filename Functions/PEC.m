classdef PEC
    properties
        file
        name
        element
        normal
        p1,p2,p3
    end

    methods
        
        function init = PEC(file)
            init.file = file;
            
            %
            % obj = readObj(fname)
            %
            % This function parses wavefront object data
            % It reads the mesh vertices, texture coordinates, normal coordinates
            % and face definitions(grouped by number of vertices) in a .obj file 
            % 
            % INPUT: fname - wavefront object file full path
            %
            % OUTPUT: init.element.v - mesh vertices
            %       : init.element.vt - texture coordinates
            %       : init.element.vn - normal coordinates
            %       : init.element.f - face definition assuming faces are made of of 3 vertices
            %
            % Bernard Abayowa, Tec^Edge
            % 11/8/07
            
            % set up field types
            vertex = []; textureCoor = []; normCoor = []; f.v = []; f.vt = []; f.vn = [];
            
            fid = fopen(file);
            % parse .obj file 
            while 1    
                tline = fgetl(fid);
                if ~ischar(tline),   break,   end  % exit at end of file 
                 ln = sscanf(tline,'%s',1); % line type 
                 %disp(ln)
                switch ln
                    case 'v'   % mesh vertexs
                        vertex = [vertex; sscanf(tline(2:end),'%f')'];
                    case 'vt'  % texture coordinate
                        textureCoor = [textureCoor; sscanf(tline(3:end),'%f')'];
                    case 'vn'  % normal coordinate
                        normCoor = [normCoor; sscanf(tline(3:end),'%f')'];
                    case 'f'   % face definition
                        fv = []; fvt = []; fvn = [];
                        str = textscan(tline(2:end),'%s'); str = str{1};
                   
                       nf = length(findstr(str{1},'/')); % number of fields with this face vertices
            
            
                       [tok str] = strtok(str,'//');     % vertex only
                        for k = 1:length(tok) fv = [fv str2num(tok{k})]; end
                       
                        if (nf > 0) 
                        [tok str] = strtok(str,'//');   % add texture coordinates
                            for k = 1:length(tok) fvt = [fvt str2num(tok{k})]; end
                        end
                        if (nf > 1) 
                        [tok str] = strtok(str,'//');   % add normal coordinates
                            for k = 1:length(tok) fvn = [fvn str2num(tok{k})]; end
                        end
                         f.v = [f.v; fv]; f.vt = [f.vt; fvt]; f.vn = [f.vn; fvn];
                end
            end
            fclose(fid);
            
            % set up matlab object 
            init.element.v = vertex; init.element.vt = textureCoor; 
            init.element.vn = normCoor; init.element.f = f;
            
            init.p1 = init.element.v(init.element.f.v(:,1),1:3);
            init.p2 = init.element.v(init.element.f.v(:,2),1:3);
            init.p3 = init.element.v(init.element.f.v(:,3),1:3);
            init.normal = cross(init.p2-init.p1,init.p3-init.p1);
            init.normal = init.normal./norm(init.normal);
        
    end
        
    function v = potencial(obj,obsPoint)
            
            O = [0,0,0];
            r = obsPoint-O;
            pts = zeros(length(obj.p1),3,3);
            pts(:,:,1) = obj.p2;
            pts(:,:,2) = obj.p3;
            pts(:,:,3) = obj.p1;
            R_p = obsPoint - pts;

            pts(:,:,1) = obj.p1;
            pts(:,:,2) = obj.p2;
            pts(:,:,3) = obj.p3;
            R_m = obsPoint - pts;
            
            R(:,:,1) = obsPoint - (obj.p1+obj.p2)*0.5;
            R(:,:,2) = obsPoint - (obj.p2+obj.p3)*0.5;
            R(:,:,3) = obsPoint - (obj.p3+obj.p1)*0.5;

            P_p = R_p-obj.normal.*(sum(R_p.*obj.normal));
            P_m = R_m-obj.normal.*(sum(R_m.*obj.normal));
            P = R-obj.normal.*(sum(R.*obj.normal));

            l(:,:,1) = (R_p(:,:,1)-R_m(:,:,1))./norm(R_p(:,:,1)-R_m(:,:,1));
            l(:,:,2) = (R_p(:,:,2)-R_m(:,:,2))./norm(R_p(:,:,3)-R_m(:,:,3));
            l(:,:,3) = (R_p(:,:,3)-R_m(:,:,3))./norm(R_p(:,:,3)-R_m(:,:,3));
            
            u(:,:,1) = cross(l(:,:,1),obj.normal);
            u(:,:,2) = cross(l(:,:,2),obj.normal);
            u(:,:,3) = cross(l(:,:,3),obj.normal);

            l_p = sum((P_p-P).*l);
            l_m = sum((P_m-P).*l);
            
            d = norm(R_m(:,:,1)-P_m(:,:,1));

            P0 = sum((P_m-P).*u);
            R0 = sqrt((P0.^2)+d.^2);
            
            % Falta terminar

            v = sum(P0.*log((R_p+l_p)./(R_m+l_m)) - ...
                abs(d).*(atan((P0.*l_p)./((R0.^2+abs(d).*R_p)))-...
                atan((P0.*l_m)./((R0.^2+abs(d).*R_m)))));

        end
        
    end
end