classdef Simulation
    properties
        shapesFolder = 'Shapes'
        files
        elements
    end

    methods        
        function init = Simulation()
            init.files = dir(fullfile(init.shapesFolder,'*.obj'));
            init.files = string({init.files.name})';
            init.elements = [];
            for i = 1:length(init.files)
                init.elements = [init.elements; PEC(init.shapesFolder+"\"+init.files(i))];
            end
        end
        
        function self = patchElements(self)
            obj = self.elements;
            disp(obj(1,1))
            figure();
            hold on,
            FC = [1 1 1];
            for i = 1:length(self.elements)
                V = obj(i,1).element.v(:, 1:3);
                F = [obj(i,1).element.f.v, obj(i,1).element.f.v(:, 1)];
                patch('Faces',F,'Vertices',V, 'FaceColor', FC)
            end
            
            axis vis3d
            axis padded
            grid on;
            grid minor;
        end
% 
%         function obj = sumar(obj,c,d)
%             obj.a = c+d;
%             obj = c+d;
%         end

    end
end
