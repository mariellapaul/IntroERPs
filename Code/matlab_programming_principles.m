%% variables
a = 1;
b = a;
c = a + b;
d = 'hello';
% starts a comment (ignored by compiler)
% ; suppresses output

%% vectors + matrices

vec = [3 8 2 6]
e = vec(1)

vec2 = [0 1 0 1]
sum = vec + vec2

mat = [2 3 9; 1 4 8]
f = mat(1,2)
g = mat(2,1)

%% cell arrays
name_subj =  {'01', '02', '03', '04', '05', '06'};

g = name_subj(1)

h = name_subj{1}

%% structures

subject.name = 'mariella';
subject.age = 26;
subject.cell = {1 2 3 4};

%% help function

help disp

%% for loops

for i = 1:2
    disp(i)
end

for i = 1:length(vec)
    
	disp(vec(i))
    
end

%% plotting

x = -pi:0.01:pi;

plot(x, sin(x))
figure;
plot(x, cos(x))

%% error messages
    
displ

disp

vec(5)

h{(a+3)*(4+g}