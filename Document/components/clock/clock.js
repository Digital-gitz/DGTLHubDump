//The formula for the X coordinate is radius + (radius * cos(degree)). Let’s plug that into our new --_x variable:
--_x: calc(var(--_r) + (var(--_r) * cos(var(--_d))));

//The formula for the Y coordinate is radius + (radius * sin(degree)). We have what we need to calculate that:
--_y: calc(var(--_r) + (var(--_r) * sin(var(--_d))));


--_r: calc((var(--_w) - var(--_sz)) / 2);
