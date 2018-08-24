function config =setup(file)

% open file
fid=fopen(file);

% read first line
t=fgetl(fid);
while isempty(t)==1
    t=fgetl(fid);
end

while t~=-1

    eval(t);
    t=fgetl(fid);
    while isempty(t)==1
        t=fgetl(fid);
    end
    
end

fclose(fid);