classdef Core
    properties
        shapesFolder = 'Shapes'
        files
        elements
    end
    
    methods        
        function init = Core()
            init.files = dir(fullfile(init.shapesFolder,'*.obj'));
            init.files = string({init.files.name})';
        end
            
        function obj = addElements(init)
            disp(init.files)
            for i = length(init.files)
                init.elements = [init.elements, PEC(init.shapesFolder+"\"+init.files(i))];
            end
        end

    end
end
