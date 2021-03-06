function [up_image, x0, f_r] = calc_up_range(vertexs, faces, level_plane)
% 

minX = min(vertexs(:,1));
maxX = max(vertexs(:,1));
minY = min(vertexs(:,2));
maxY = max(vertexs(:,2));
minZ = min(vertexs(:,3));

if maxX - minX < 150
    midX = (minX + maxX) / 2;
    minX = midX - 75;
    maxX = midX + 75;
end
if maxY - minY < 150
    midY = (minY + maxY) / 2;
    minY = midY - 75;
    maxY = midY + 75;
end
scale = 10;
x0 = [minX:1/scale:maxX];
y0 = [minY:1/scale:maxY];
up_image = zeros(length(x0), length(y0));

center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
center_points(:,3) = center_points(:,3) - minZ;
for i = 1 : length(center_points)
    
    x = floor((center_points(i,1) - minX) * scale) + 1;
    y = floor((center_points(i,2) - minY) * scale) + 1;
    z = center_points(i,3);
    
    if z < level_plane
        continue
    end
    
    if up_image(x, y) == 0
        up_image(x, y) = z;
    else
        up_image(x, y) = max(up_image(x, y), z);
    end  
end

count = 1;
temp = up_image;
image_deco = up_image;
points = zeros(1,2);
while count < 30
    [x y] = find(temp == max(max(temp)));
    temp(x-50:x+50, y-50:y + 50) = 0;
    points(count, :) =[x y];
    image_deco(x-5:x+5, y-5:y+5) = 1000;
    count = count + 1;
end

points = sortrows(points);
points(:,1) = (points(:,1) - 1) / scale + minX;
points(:,2) = (points(:,2) - 1) / scale + minY;

f = polyfit(points(:,1),points(:,2),3);
points_f = polyval(f, points(:,1));
while length(find(points(:,2) > points_f)) > 3
    f(4) = f(4) + 1;
    points_f = polyval(f, points(:,1));
end

%f(x)f'(x)-y0f'(x)+x-x0=0;
x = [length(f)-1:-1:1];
f_derv = f(1:end-1).*x;%f'(x)
f_f_derv = conv(f,f_derv);%f(x)f'(x)
depth = zeros(1,2);
for i = 1:length(points)
    xy = points(i,:);
    depth(i,1) = 1000;
    f_tangent=f_f_derv+[0 0 0 -1*xy(1)*f_derv] +[0 0 0 0 1 -1*xy(1)];
    res = roots(f_tangent);
    for j = 1:length(res)
        if isreal(res(j))
            depth_cur = norm([(res(j)-xy(1)), (xy(2) - polyval(f, res(j)))]);
            if depth_cur < depth(i,1) 
                depth(i,1) = depth_cur;
            end
        end
    end
end
depth(:,2) = [1 : length(depth)];
depth = sortrows(depth,1);
points_result = points(depth(1:20,2),:);

f_r = polyfit(points_result(:,1),points_result(:,2),4);

points_f = polyval(f_r, points_result(:,1));
while length(find(points_result(:,2) > points_f)) > 3
    f_r(5) = f_r(5) + 1;
    points_f = polyval(f_r, points_result(:,1));
end
% figure(1)
% clf;
% hold on;
% scatter(points(:,1), points(:,2), 'g.');
% scatter(points_result(:,1), points_result(:,2), 'bo');
% scatter(points_result(:,1), polyval(f_r, points_result(:,1)), 'r*');
% hold off;

% image(image_deco);


