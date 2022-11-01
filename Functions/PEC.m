classdef PEC
    properties
        file
        name
        element
        normal
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
            
            p1 = init.element.v(init.element.f.v(:,1),1:3);
            p2 = init.element.v(init.element.f.v(:,2),1:3);
            p3 = init.element.v(init.element.f.v(:,3),1:3);
            init.normal = cross(p2-p1,p3-p1);
            init.normal = init.normal./norm(init.normal);
        
    end
        
        function out = vec2obsPoint(obj,obsPoint)
            
            O = [0,0,0];
            r = obsPoint-O;
            rho = r-obj.normal.*(sum(r.*obj.normal));
            

        end
        
    end
end