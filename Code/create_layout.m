%% Prepare layout structure for P1

cfg = [];
cfg.image = 'easycapm11.jpg';
lay = ft_prepare_layout(cfg);

lay.label = {'Oz' 'POz' 'Pz' 'PO3' 'C5' 'P3' 'P7' 'CP5' 'CPz' 'Cz' ...
    'FCz' 'FC3' 'C3' 'F3' 'F5' 'F7' 'FPz' 'Fp2' 'AFz' 'Fz' 'C4' 'FC4' 'F4'...
    'F8' 'P8' 'P4' 'C6' 'PO4' 'F6' 'CP6' 'VEOG' 'M2' ...
    'COMNT' 'SCALE'};

cfg = [];
%cfg.image  = 'easycapm11.png'; % use the photo as background
% you'll find this image, as well as other standard layouts on the FieldTrip homepage
% http://www.fieldtriptoolbox.org/template/layout/
cfg.layout = lay; % this is the layout structure that you created with ft_prepare_layout
ft_layoutplot(cfg);
lay.outline = lay.mask;
save layout.mat lay 
