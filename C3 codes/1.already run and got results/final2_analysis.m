clc;clear;close all;
number_sand = 200; 
number_sand=gpuArray(number_sand);
N=23;% table length
M=23;% table width

sand_pile = gpuArray(zeros(N,M));
add=2;

avalanche_count = 0;
Mean_matrix = zeros(number_sand,1);
avalanche_matrix = zeros(10000,1); % create a empty matrix

interval=1; % every 1000 sand drops polt a graph.
frames(number_sand/interval)=struct('cdata',[],'colormap',[]);
bi=1; %index of images

for i=1:number_sand 
    pause(0.001)
    sand_pile(ceil(N/2),ceil(M/2)) = sand_pile(ceil(N/2),ceil(M/2)) + add;
   
    [x_coord_tops,y_coord_tops] = find(sand_pile>3);
    x_coord_tops=gpuArray(x_coord_tops);
    y_coord_tops=gpuArray(y_coord_tops);
    number_top = length(x_coord_tops);
    number_top = gpuArray(number_top);

    avalanche_matrix(i,1) = number_top;

    while number_top > 0
        for j = 1: number_top
            %avalanche_count = avalanche_count + 1;
            if x_coord_tops(j)==1 || y_coord_tops(j)==1 || x_coord_tops(j)==N || y_coord_tops(j)==M   % or        
            sand_pile(x_coord_tops(j),y_coord_tops(j))=sand_pile(x_coord_tops(j),y_coord_tops(j))-4;
            avalanche_count = avalanche_count + 1;
                if x_coord_tops(j)+1 <= N
            sand_pile(x_coord_tops(j)+1,y_coord_tops(j))=sand_pile(x_coord_tops(j)+1,y_coord_tops(j))+0;
                end
                if x_coord_tops(j)-1 >= 1
            sand_pile(x_coord_tops(j)-1,y_coord_tops(j))=sand_pile(x_coord_tops(j)-1,y_coord_tops(j))+0;
                end
                if y_coord_tops(j)+1 <= M
            sand_pile(x_coord_tops(j),y_coord_tops(j)+1)=sand_pile(x_coord_tops(j),y_coord_tops(j)+1)+0;
                end
                if y_coord_tops(j)-1 >= 1
            sand_pile(x_coord_tops(j),y_coord_tops(j)-1)=sand_pile(x_coord_tops(j),y_coord_tops(j)-1)+0;
                end
            else
               sand_pile(x_coord_tops(j),y_coord_tops(j))=sand_pile(x_coord_tops(j),y_coord_tops(j))-4;
               avalanche_count = avalanche_count + 1;
                if x_coord_tops(j) == ceil(N/2) && y_coord_tops(j)==ceil(M/2)
                 sand_pile(x_coord_tops(j)+1,y_coord_tops(j))=sand_pile(x_coord_tops(j)+1,y_coord_tops(j))+add;
                 sand_pile(x_coord_tops(j)-1,y_coord_tops(j))=sand_pile(x_coord_tops(j)-1,y_coord_tops(j))+add;
                 sand_pile(x_coord_tops(j),y_coord_tops(j)+1)=sand_pile(x_coord_tops(j),y_coord_tops(j)+1)+add;
                 sand_pile(x_coord_tops(j),y_coord_tops(j)-1)=sand_pile(x_coord_tops(j),y_coord_tops(j)-1)+add;
                end
                if x_coord_tops(j) < ceil(N/2) && y_coord_tops(j)>=ceil(M/2)
                 sand_pile(x_coord_tops(j)-1,y_coord_tops(j))=sand_pile(x_coord_tops(j)-1,y_coord_tops(j))+add;
                 sand_pile(x_coord_tops(j),y_coord_tops(j)+1)=sand_pile(x_coord_tops(j),y_coord_tops(j)+1)+add;
                end
                if x_coord_tops(j) >= ceil(N/2) && y_coord_tops(j)>ceil(M/2)
                sand_pile(x_coord_tops(j)+1,y_coord_tops(j))=sand_pile(x_coord_tops(j)+1,y_coord_tops(j))+add;
                sand_pile(x_coord_tops(j),y_coord_tops(j)+1)=sand_pile(x_coord_tops(j),y_coord_tops(j)+1)+add;
                end
                if x_coord_tops(j) > ceil(N/2) && y_coord_tops(j)<=ceil(M/2)
                sand_pile(x_coord_tops(j)+1,y_coord_tops(j))=sand_pile(x_coord_tops(j)+1,y_coord_tops(j))+add;
                sand_pile(x_coord_tops(j),y_coord_tops(j)-1)=sand_pile(x_coord_tops(j),y_coord_tops(j)-1)+add;
                end
                if x_coord_tops(j) <= ceil(N/2) && y_coord_tops(j)<ceil(M/2)
                sand_pile(x_coord_tops(j)-1,y_coord_tops(j))=sand_pile(x_coord_tops(j)-1,y_coord_tops(j))+add;
                sand_pile(x_coord_tops(j),y_coord_tops(j)-1)=sand_pile(x_coord_tops(j),y_coord_tops(j)-1)+add;
                end
            end
        end
        [x_coord_tops,y_coord_tops] = find(sand_pile>3);
        number_top = length(x_coord_tops);

        x_coord_tops=gpuArray(x_coord_tops);
        y_coord_tops=gpuArray(y_coord_tops);
        number_top = gpuArray(number_top);
        avalanche_matrix(i,1) = avalanche_matrix(i,1) + number_top;
    
    end
    Mean_matrix(i,1) = mean(sand_pile,"all");
%imagesc(sand_pile)
Mean_matrix(i,1) = mean(sand_pile,"all");

    if mod(i,interval)==0 %for each time statisfy the interval,draw graph.
        image(sand_pile,'CDataMapping','scaled')
        colorbar
        graphsetting([0.2 0.1 0.6 0.8]); %percentage of the graph size corresponding to computer screen.
        str=['number of sand: ',sprintf('%d',i)];
        set(text(0,0,str),'interpreter','latex','HorizontalAlignment','left');    
        drawnow;
        frames(bi) = getframe(gcf);
        bi=bi+1;
    end


empty_sandpile=zeros(N,M);
empty_sandpile=gpuArray(empty_sandpile);

for t=1:((((N)+1)/2)-1)
    M2 = sand_pile(t:(N-(t-1)),t:(M-(t-1)));
    M2=gpuArray(M2);
    Length_matrix=length(M2);
    Length_matrix=gpuArray(Length_matrix);

    M1=zeros(length(M2),length(M2)); 
    M1=gpuArray(M1);

    [x_coord,y_coord]= find(M2>=0);
    x_coord = gpuArray(x_coord);
    y_coord = gpuArray(y_coord);   
    for k=1:length(x_coord)
        if (x_coord(k) == 1) && (y_coord(k) == 1)
            M1(x_coord(k),y_coord(k)+1) = M2(x_coord(k),y_coord(k));
        elseif (x_coord(k) == 1) && (y_coord(k) == Length_matrix)
            M1(x_coord(k)+1,y_coord(k)) = M2(x_coord(k),y_coord(k)); 
        elseif (x_coord(k) == Length_matrix) && (y_coord(k) == Length_matrix)
            M1(x_coord(k),y_coord(k)-1) = M2(x_coord(k),y_coord(k));
        elseif (x_coord(k) == Length_matrix) && (y_coord(k) == 1)
            M1(x_coord(k)-1,y_coord(k)) = M2(x_coord(k),y_coord(k));
        elseif (x_coord(k) == 1) && (y_coord(k) ~= 1) && (y_coord(k) ~= Length_matrix)
            M1(x_coord(k),y_coord(k)+1) = M2(x_coord(k),y_coord(k));
        elseif (y_coord(k) == Length_matrix) && (x_coord(k)~=1) && (x_coord(k)~=Length_matrix)
            M1(x_coord(k)+1,y_coord(k)) = M2(x_coord(k),y_coord(k)); 
        elseif (x_coord(k) == Length_matrix) && (y_coord(k) ~= Length_matrix) && (y_coord(k) ~= 1)
            M1(x_coord(k),y_coord(k)-1) = M2(x_coord(k),y_coord(k));
        elseif (y_coord(k) == 1) && (x_coord(k)~=1) && (x_coord(k)~=Length_matrix)
            M1(x_coord(k)-1,y_coord(k)) = M2(x_coord(k),y_coord(k));
        end
    end
empty_sandpile(t:(N-(t-1)),t:(N-(t-1)))=M1;
empty_sandpile((N+1)/2,(N+1)/2)=sand_pile((N+1)/2,(N+1)/2);
end

sand_pile=empty_sandpile;

end





count = avalanche_count;

%histogram(sand_pile(:))

% plot the mean sand number in the table over time
figure(2)
X = [1:1:number_sand];
plot(X,Mean_matrix)
title('Mean number of sand over time')
ylabel('Mean number')
xlabel('time')


% for the avalanche size and frequency:
B = avalanche_matrix(find(avalanche_matrix~=0)); % delete any zero element in the vetor and create a new vector that contain only non zero elments. 
% That is, the matrix with avalanche size.
Max_number_in_B = max(B); % detect the maximum avalanche size.
X1=[1:1:Max_number_in_B]'; % create the x axis element for the plot, that is, the avalanche size form 1 to the maximum size.
Y1=zeros(Max_number_in_B,1); % create a empty matrix for the x axis for the plot, now is null but we will add elemets into it later.

for k=1:Max_number_in_B % for each possible size k of avalanche
C = numel(find(avalanche_matrix==k)); % check the frequency of size k of avalanche
Y1(k,1)=C; % put the frequenct of size k into our matrix Y1
end
% plot the log of avalanche size vs log of frequency
figure(3)
plot(log(X1),log(Y1)) % do the log sclae plot
ylabel('log of avalanche size')
xlabel('log of frequency')
title('log(avalanche size) vs log(frequency) plot')

% nozero_Y1 = Y1(find(Y1~=0));

X1(Y1==0)=[];
Y1(Y1==0)=[];

log_X1 = log(X1);
log_Y1 = log(Y1);
mdl = fitlm(log_X1,log_Y1);

mdl.Coefficients
anova(mdl,'summary')
figure(4)
plot(mdl)
ylabel('log of avalanche size')
xlabel('log of frequency')
title('log(avalanche size) vs log(frequency) plot')

% create video
Video = VideoWriter('random added sandpile','MPEG-4');
open(Video);
writeVideo(Video,frames)
close(Video);

function graphsetting(setting)
    set(0,'units','centimeters') % we want to get unit in cm.
    computerscreensize=get(0,'screensize');  
    Length = computerscreensize(3); %length of computer screen
    Height = computerscreensize(4); %height of computer screen
    position=[setting(1)*Length setting(2)*Height setting(3)*Length setting(4)*Height];
    set(gcf,'units','centimeters','position',position); %Set the position & size of graph.
end




