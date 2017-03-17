%% SPC 2013
%  Markéta Jedlièková

close all
clear all

%%  Image reading

structure = load('dataHypoMeta.mat');
allCenters = []; 

index = 1;
trida = 1;

for i = 1:size(structure.mask,3)
    mask = uint8(structure.mask(:,:,i));
    img = uint8(structure.data3d(:,:,i));
    
    imgNew{i,:} = img.*mask;
    
    % Edge detection and Hough transform application
    
    %figure(i); imshow(imgNew{i,1});
    
    imgEdge = edge(imgNew{i,1},'canny', 0.05);
    [centers, radii, metric]=imfindcircles(imgEdge,[10 30], 'Sensitivity', 0.88);
     
    %figure(i); imshow(imgEdge);
    figure(1); subplot(6,6,i); imshow(imgEdge);
    
    % ulozeni vsech stredu do jedny tabulky
    [m,n] = size(centers);
    if m ~= 0
        posun = index + m - 1;
        allCenters(index: posun,1:2) = centers;
        allCenters(index: posun,3) = radii;
        allCenters(index: posun,4) = trida;
        index = index + m;
        trida = trida + 1;
    end
end

%% Získání støedu
[ids, ctrs] =  kmeans(allCenters(:,1:2),5,'replicates', 100);

color = {'b+','m+','r+','g+','c+'};
for j = 1:5
    g = find(ids==j);
    plot(allCenters(g,1), allCenters(g,2), color{j});
    hold on
    soucet = abs(allCenters(g,1)-ctrs(j,1));
    soucet2 = abs(allCenters(g,2)-ctrs(j,2));
    soucty{j} = (sum(soucet)+sum(soucet2))/length(g);
    
    soucty2 = cell2mat(soucty);
    idsMin = find(soucty2==min(soucty2));
end

chtene = find(ids==idsMin);
chteneSouradnice = allCenters(chtene,1:4);

%% Eliminace tìch kruhù které mají støedy blízko sebe

[id, stred] =  kmeans(chteneSouradnice(:,1:2),1,'replicates', 100);

velikost = size(chteneSouradnice);
noveChtene = [];
l = 1;
for i = 1: velikost(1)
    rozdilSouradnic = sqrt((stred(1) - chteneSouradnice(i,1))^2 + (stred(2) - chteneSouradnice(i,2))^2);
    if rozdilSouradnic < 4.6   % Hypo 4.6
     rozdilSouradnic
     noveChtene(l,1:4) = chteneSouradnice(i,1:4);
     l = l + 1;
    end
end

%% zobrazeni jen chtenych kruhu
for k = 1:31
    
    figure(2);
    subplot(7,5,k); 
    %figure(k); 
    imshow(imgNew{k,1})
    hold on
    
    h = find(noveChtene(:,4)==k);
    aktualni = noveChtene(h,1:2);
    aktualniRadii = noveChtene(h,3);
    viscircles(aktualni, aktualniRadii,'EdgeColor','b');
end

%% Postup

% Vezmu data, najdu kruhy
% najdu stredy, shlukovanim ziskam neco pribliznyho
% vezmu jen kruhy ve shluku
