clc;clear;close all;
numArrays = 50;
N_ring= cell(numArrays,1);
th_ring = cell(numArrays,1);
number_sites_ring = cell(numArrays,1);
radius_ring = cell(numArrays,1);
act_ring = cell(numArrays,1);
life_ring = cell(numArrays,1);
for n = 1:numArrays
    N_ring{n} = n;
    th_ring{n} = 2*pi/(n*6):2*pi/(n*6):2*pi;
    number_sites_ring{n} = length(th_ring{n});
    radius_ring{n} = n*ones(1, number_sites_ring{n});
    act_ring{n} = zeros(1,number_sites_ring{n});
    life_ring{n} = zeros(1,number_sites_ring{n});
    ring{n} = [th_ring{n}; radius_ring{n}; act_ring{n}; life_ring{n}; zeros(1,number_sites_ring{n})];
end

for n=1:4
        center_const_keep{1,n}=ring{n};
end
center_const=[center_const_keep{:}];

number_sand = 150;
p_sp=0.0002;
p_st=0.28;
p_st_h=0.28;
regeneration_time = 11; 

%0.0002/0.22/0.18/11/12345
%0.0002/0.25/0.18/11/13579


interval=1; % every few sand drops polt a graph.
frames(number_sand/interval)=struct('cdata',[],'colormap',[]);
bb=1; %index of images

for i=1:number_sand
    pause(1)


    for n=1:50
        [in_active_position] = find(ring{n}(3,:) > 0);
        for g=1:length(in_active_position)
            ring{n}(3,in_active_position(g)) = ring{n}(3,in_active_position(g)) - 1; 
        end
    end

    for n=1:50
        [active_position] = find(ring{n}(3,:) <= 0);
        for b=1:length(active_position)
            active_or_not_for_this_site = rand;
            if active_or_not_for_this_site <= p_sp
               ring{n}(5,active_position(b)) = ring{n}(5,active_position(b)) + 1;
               ring{n}(3,active_position(b)) = ring{n}(3,active_position(b)) + regeneration_time;
               
            end
        end
    end
    
    for n=1:50
        sand_pile_zero{1,n}=ring{n};
    end
    sand_pile=[sand_pile_zero{:}];
    [exist_position]=find(sand_pile(5,:) > 0);
 

    for n=1:50
        [position_tops] = find(ring{n}(5,:) > 0);
        for j=1:length(position_tops)
            ring{n}(5,position_tops(j)) = 0;
            theta_top_now  = ring{n}(1,position_tops(j));
            radius_top_now = ring{n}(2,position_tops(j));

            ring{n}(3,position_tops(j)) = ring{n}(3,position_tops(j)) + regeneration_time;
            
            radius_now = gpuArray(radius_top_now);
            theta_now  = gpuArray(rad2deg(theta_top_now));

               radius_same  = gpuArray(ring{n}(2,:));
               theta_same   = gpuArray(ring{n}(1,:));
               radius_now_square=radius_now^2;
               radius_now_new = ones(1,length(radius_same))*radius_now_square;
               d_square = radius_now_new + radius_same.^2 - (2 * radius_now * radius_same .* cos(theta_now - theta_same));
               [B,I] = mink(d_square,2);
               [active_position] = find(ring{n}(3,:) <= 0);
               for q=2:length(I)
                   if ismember(I(q),active_position)==1
                   active_or_not_here1 = rand;
                      if active_or_not_here1 <= p_st_h 
                         ring{n}(5,I(q)) = ring{n}(5,I(q)) + 1;
                         ring{n}(3,I(q)) = ring{n}(3,I(q)) + regeneration_time;
                       end
                    end
                end 

            if n+1 <=50
               radius_up  = gpuArray(ring{n+1}(2,:));
               theta_up   = gpuArray(ring{n+1}(1,:));
               radius_now_square=radius_now^2;
               radius_now_new = ones(1,length(radius_up))*radius_now_square;
               d_square = radius_now_new + radius_up.^2 - (2 * radius_now * radius_up .* cos(theta_now - theta_up));
               [B,I] = mink(d_square,2);
               [active_position] = find(ring{n+1}(3,:) <= 0);
               for q=1:length(I)
                   if ismember(I(q),active_position)==1
                   active_or_not_here2 = rand;
                      if active_or_not_here2 <= p_st 
                         ring{n+1}(5,I(q)) = ring{n+1}(5,I(q)) + 1;
                         ring{n+1}(3,I(q)) = ring{n+1}(3,I(q)) + regeneration_time;
                       end
                    end
                end 
            end
            if n-1 >=1
               radius_down  = gpuArray(ring{n-1}(2,:));
               theta_down   = gpuArray(ring{n-1}(1,:));
               radius_now_square=radius_now^2;
               radius_now_new = ones(1,length(radius_down))*radius_now_square;
               d_square = radius_now_new + radius_down.^2 - (2 * radius_now * radius_down .* cos(theta_now - theta_down));
               [B,I] = mink(d_square,2);
               [active_position] = find(ring{n-1}(3,:) <= 0);
               for q=1:length(I)
                   if ismember(I(q),active_position)==1
                   active_or_not_here3 = rand;
                      if active_or_not_here3 <= p_st 
                         ring{n-1}(5,I(q)) = ring{n-1}(5,I(q)) + 1;
                         ring{n-1}(3,I(q)) = ring{n-1}(3,I(q)) + regeneration_time;
                       end
                    end
                end 
            end    
        end
    end
    
    for n=1:50
        sand_pile_one{1,n}=ring{n};
    end
    
    sand_pile2=[sand_pile_one{:}];
    [exist_position2]=find(sand_pile2(5,:) > 0);

    history_two_step_before{i} = sand_pile;
    [exist_position_two_step{i}]= exist_position;
    history_one_step_before{i} = sand_pile2;
    [exist_position_one_step{i}]= exist_position2;


    if mod(i,interval)==0 
    c = "black";
 



 
    
    polarscatter(sand_pile(1,exist_position),sand_pile(2,exist_position),[],"pentagram","filled","c");
    colormap(flipud(gray))
    rlim([0 55])
    axis off
    graphsetting([0.2 0.1 0.6 0.8]);  
    title(['number of sand: ',sprintf('%d',i)])
    drawnow;
    frames(bb) = getframe(gcf);
    bb=bb+1;
    hold on

    polarscatter(sand_pile2(1,exist_position2),sand_pile2(2,exist_position2),[],"hexagram","filled","b");
    colormap(flipud(gray))
    axis off
    rlim([0 55])
    hold off
    graphsetting([0.2 0.1 0.6 0.8]);  
    title(['number of sand: ',sprintf('%d',i)])
    drawnow;
    frames(bb) = getframe(gcf);
    bb=bb+1;
    end

    V=[1 3 5 7 9];
    for n=1:10
        ring{n}(5,:)=circshift(ring{n}(5,:),V(1));
        ring{n} = [th_ring{n}; radius_ring{n}; act_ring{n}; life_ring{n}; ring{n}(5,:)];
    end
    for n=11:20
        ring{n}(5,:)=circshift(ring{n}(5,:),V(2));
        ring{n} = [th_ring{n}; radius_ring{n}; act_ring{n}; life_ring{n}; ring{n}(5,:)];
    end
    for n=21:30
        ring{n}(5,:)=circshift(ring{n}(5,:),V(3));
        ring{n} = [th_ring{n}; radius_ring{n}; act_ring{n}; life_ring{n}; ring{n}(5,:)];
    end
    for n=31:40
        ring{n}(5,:)=circshift(ring{n}(5,:),V(4));
        ring{n} = [th_ring{n}; radius_ring{n}; act_ring{n}; life_ring{n}; ring{n}(5,:)];
    end
    for n=41:50
        ring{n}(5,:)=circshift(ring{n}(5,:),V(5));
        ring{n} = [th_ring{n}; radius_ring{n}; act_ring{n}; life_ring{n}; ring{n}(5,:)];
    end
  
 
end




Video = VideoWriter('galaxy','MPEG-4');
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