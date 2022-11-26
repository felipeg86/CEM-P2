classdef Simulation
    properties
        folder
        files
        bodies
        elements
        epsilon_0
        ke 
        totalTriangles
    end

    methods    
        function obj = Simulation(folder, characteristics)
            obj.files = dir(fullfile(folder,'*.obj'));
            obj.files = string({obj.files.name})';
            obj.folder = folder;
            obj.elements = length(obj.files);
            obj.epsilon_0  = 8.8541878128E-12;
            obj.ke = 1/(4*pi*obj.epsilon_0);
            obj.totalTriangles = 0;
            for i = 1:length(obj.files)
                obj.bodies.("body"+i) = PEC(obj.folder+"\"+obj.files(i),characteristics.("body"+i));
                obj.totalTriangles = obj.totalTriangles + obj.bodies.("body"+i).triangles;
            end

        end

        function [] = patchElements(obj)
            figure();
            hold on,
            FC = [1 1 1];

            for i = 1:obj.elements
                V = obj.bodies.("body"+i).geometry.v(:, 1:3);
                F = [obj.bodies.("body"+i).geometry.f.v, obj.bodies.("body"+i).geometry.f.v(:, 1)];
                patch('Faces',F,'Vertices',V, 'FaceColor', FC)
            end
            view([45 35.264]);
            axis equal
            grid on;
            grid minor;
        end
        
        function Q = computeCapacitanceMatrix(obj)
            %capMatrix = zeros(obj.elements, obj.elements);
            % Maxwell Capacitance Matrix
            A = rand(obj.totalTriangles);
            for i = 1:obj.totalTriangles
                for j = 1:obj.totalTriangles
                    A(i,j) = 2;
                end
            end

            sigma = zeros(obj.totalTriangles, obj.elements);
            areas = zeros(1, obj.totalTriangles);
            Q = zeros(obj.elements);
            position = 1;
            
            for m = 1:obj.elements
                voltages = zeros(obj.totalTriangles,1);
                voltages(position+1:obj.bodies.("body"+m).triangles+position) ...
                        = obj.bodies.("body"+m).characteristics.boundaryCondition; 
                areas(position+1:obj.bodies.("body"+m).triangles+position)...
                    = obj.bodies.("body"+m).getTriangleAreas();
                position = obj.bodies.("body"+m).triangles;
                sigma(:,m) =A\voltages;
            end
            
            for m = 1:obj.elements
                for n = 1:obj.totalTriangles
                    a = zeros(obj.elements,obj.totalTriangles);
                    a(:,n) = areas(:,n);
                end
                Q(:,m) = a(m,:)*sigma;
            end
            

%             for n = 1:size(capMatrix,2)
%                 for m = 1:size(capMatrix, 2)
%                     chargeBodym = obj.bodies.("body"+m).characteristics.charge;
%                     voltageBodyn = obj.bodies.("body"+n).computeVoltage(GND);
%                         capMatrix(m, n) = chargeBodym/voltageBodyn;
%                         %disp(obj.geometries.("body"+n).characteristics.charge)
%                 end
%             end

            % Mutual capacitance
           
%             for n = 1:size(capMatrix,2)
%                 for m = 1:size(capMatrix, 2)
%                     charges(m) = obj.geometries.("body"+m).characteristics.charge;
%                 end
%                 voltageBodyn = obj.geometries.("body"+n).computeVoltage(GND);
%                 disp(voltageBodyn)
%                 capMatrix(:,n) = (charges/voltageBodyn)';
%             end


        end
    
    end

end
