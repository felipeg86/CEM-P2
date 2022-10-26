function [] = plotElements(elements)
    
    obj = elements;
    V = obj.v(:, 1:3);
    F = [obj.f.v, obj.f.v(:, 1)]; 
    
    figure();
    FC = [1 1 1];
    patch('Faces',F,'Vertices',V, 'FaceColor', FC)
    axis vis3d
    axis padded
    grid on;
    grid minor;
end