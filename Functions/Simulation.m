classdef Simulation
    properties
        shapesFolder = 'Shapes'
        files
        elements
        norm
        a = 0
    end

    methods    
        function init = Simulation()
            init.files = dir(fullfile(init.shapesFolder,'*.obj'));
            init.files = string({init.files.name})';
            init.elements = [];
            for i = 1:length(init.files)
                newElement = PEC(init.shapesFolder+"\"+init.files(i));
                init.elements = [init.elements; newElement];
            end
        end
        
        function [] = patchElements(self)
            obj = self.elements;
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

    end
end
