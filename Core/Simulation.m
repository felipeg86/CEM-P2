classdef Simulation
    properties
        folder
        files
        bodies
        elements 
        totalTriangles
    end

    methods    
        function obj = Simulation(folder, inputParametersFiles)
            delete Results\*.txt Results\*.csv       
            
            inputParameters = importdata(inputParametersFiles).data;

            obj.files = dir(fullfile(folder,'*.obj'));
            obj.files = string({obj.files.name})';
            obj.folder = folder;
            obj.elements = length(obj.files);
            obj.totalTriangles = 0;
            for m = 1:length(obj.files)
                characteristics.boundaryCondition = inputParameters(m);
                obj.bodies.("body"+m) = PEC(obj.folder+"\"+obj.files(m),characteristics);
                obj.totalTriangles = obj.totalTriangles + obj.bodies.("body"+m).triangles;
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
            title('Simulation'),
            xlabel('Position [mm]')
            ylabel('Position [mm]')
            zlabel('Position [mm]')
            axis equal
            grid on;
            grid minor;
        end
        
        function outputData = computeCapacitanceMatrix(obj)
            e0  = 8.8541878128E-12;

            % Maxwell Capacitance Matrix
            areas = zeros(1, obj.totalTriangles);
            centers = zeros(3, obj.totalTriangles);
            vertex.A = zeros(3, obj.totalTriangles);
            vertex.B = zeros(3, obj.totalTriangles);
            vertex.C = zeros(3, obj.totalTriangles);
            bodiesVoltage = zeros(obj.elements,1);
            sigma = zeros(obj.totalTriangles, obj.elements);
            Q = zeros(obj.elements);

            position = 0;
            % Get the centers and areas of all the simulation triangles

            for M = 1:obj.elements
                areas(position+1:obj.bodies.("body"+M).triangles+position)...
                    = obj.bodies.("body"+M).areas*1e-6;

                centers(:,position+1:obj.bodies.("body"+M).triangles+position)...
                    = obj.bodies.("body"+M).centers*1e-3;

                vertex.A(:,position+1:obj.bodies.("body"+M).triangles+position)...
                    = obj.bodies.("body"+M).vertex.A*1e-3;

                vertex.B(:,position+1:obj.bodies.("body"+M).triangles+position)...
                    = obj.bodies.("body"+M).vertex.B*1e-3;

                vertex.C(:,position+1:obj.bodies.("body"+M).triangles+position)...
                    = obj.bodies.("body"+M).vertex.C*1e-3;
                
                bodiesVoltage(M) = obj.bodies.("body"+M).characteristics.boundaryCondition;

                position = position + obj.bodies.("body"+M).triangles;
            end

            % compute the MoM matrix
            MoM = zeros(obj.totalTriangles);

            for m = 1:obj.totalTriangles
                for n = 1:obj.totalTriangles
                    MoM(m,n) = obj.bodies.("body1")...
                        .computeOneIntegral(centers(:,m), ...
                        vertex.A(:,n), vertex.B(:,n), vertex.C(:,n), "")/(4*pi*e0);
                end
            end

            % Compute charge density

            position = 0;
            for M = 1:obj.elements
                voltages = zeros(obj.totalTriangles,1);
                voltages(position+1:obj.bodies.("body"+M).triangles+position) ...
                        = obj.bodies.("body"+M).characteristics.boundaryCondition;
                position = position + obj.bodies.("body"+M).triangles;
                sigma(:,M) = MoM\voltages;
            end
            
            
            % Add the contribution of each area
            position = 0;

            for M = 1:obj.elements
                for N = 1:obj.totalTriangles
                    a = zeros(obj.elements,obj.totalTriangles);
                    a(:,position+1:obj.bodies.("body"+M).triangles+position) = ...
                        repmat(areas(position+1:obj.bodies.("body"+M).triangles+position),obj.elements,1);
                end
                position = position + obj.bodies.("body"+M).triangles;

                % Compute Charge Matrix
                Q(:,M) = a(M,:)*sigma;
            end 
            
            % Compute Maxwell Capacitance Matrix

            V = diag(bodiesVoltage);
            C = V\Q;

            % Compute Mutual Capacitance Matrix
                        
            A = [25, -6, -7; -2,25, -7; -1, -3, 20];
            MutualCapacitanceMatrix = abs(C);
            %s = size(A);
            
            index = 1:size(C,1)+1:size(C,1)*size(C,2);
            MutualCapacitanceMatrix(1:size(C,1)+1:size(C,1)*size(C,2)) = ...
                sum(C,2);

            disp("Charge Q")
            disp(Q)
            
            
            disp("Voltage V")
            disp(V)
            
            disp("Maxwell Capacitance Matrix")
            disp(C)
            
            disp("Mutual Capacitance Matrix")
            disp(MutualCapacitanceMatrix)

            writematrix(MoM,'Results/MoM_Matrix.csv','Delimiter','tab');
            
            if obj.elements == 2
                fileID = fopen('Results/cap2.txt','w');
                fprintf(fileID,"Two-electrode capacitance compute: "+num2str(abs(C(1,2)))+" F");
                fclose(fileID);
            end
            
            outputData.MoM_Matrix = MoM;
            outputData.ChargeDensityMatrix = sigma;
            outputData.ChargeMatrix = Q;
            outputData.MaxwellCapacitanceMatrix = C;
            outputData.MutualCapacitanceMatrix = MutualCapacitanceMatrix;

        end
    
    end

end
