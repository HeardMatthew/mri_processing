%% make_contrasts
% A script which quickly whips up contrasts. 

%% Parameters
cons = { ...
    'NOI'...
    'SIL'...
    'ORA'...
    'SRA'...
    };

move = {...
    'mov1'...
    'mov2'...
    'mov3'...
    'mov4'...
    'mov5'...
    'mov6'...
    };

phys = {...
    'phy1'...
    'phy2'...
    'phy3'...
    'phy4'...
%     'err1'...
    };

artr = {};

regs = horzcat(move, phys, artr); 
full = horzcat(cons, regs);

numCons = length(cons);
numRegs = length(regs);
numRun1 = length(full); 

%% Contrasts
contrast_identity.noi_sil = [ 1 -1 0  0];
contrast_identity.sen_noi = [-2  0 1  1];
contrast_identity.ora_sra = [ 0  0 1 -1];

contrasts = fields(contrast_identity);

%% Make contrasts
% Hybrid
numBins = 10;
for ii = 1:length(contrasts)
    c.h.(contrasts{ii}).identity = [];
    for jj = 1:numCons
        c.h.(contrasts{ii}).identity = horzcat(c.h.(contrasts{ii}).identity, repmat(contrast_identity.(contrasts{ii})(jj), 1, numBins));
    end
    c.h.(contrasts{ii}).r1 = c.h.(contrasts{ii}).identity; 
    c.h.(contrasts{ii}).r2 = horzcat(zeros(1, length(c.h.(contrasts{ii}).identity) + numRegs), c.h.(contrasts{ii}).identity);
    c.h.(contrasts{ii}).all = horzcat(c.h.(contrasts{ii}).identity, zeros(1, numRegs), c.h.(contrasts{ii}).identity);
end

% ISSS
numBins = 5;
for ii = 1:length(contrasts)
    c.i.(contrasts{ii}).identity = [];
    for jj = 1:numCons
        c.i.(contrasts{ii}).identity = horzcat(c.i.(contrasts{ii}).identity, repmat(contrast_identity.(contrasts{ii})(jj), 1, numBins));
    end
    c.i.(contrasts{ii}).r1 = c.i.(contrasts{ii}).identity; 
    c.i.(contrasts{ii}).r2 = horzcat(zeros(1, length(c.i.(contrasts{ii}).identity) + numRegs), c.i.(contrasts{ii}).identity);
    c.i.(contrasts{ii}).all = horzcat(c.i.(contrasts{ii}).identity, zeros(1, numRegs), c.i.(contrasts{ii}).identity);
end

% Multi
numBins = 1;
for ii = 1:length(contrasts)
    c.m.(contrasts{ii}).identity = [];
    for jj = 1:numCons
        c.m.(contrasts{ii}).identity = horzcat(c.m.(contrasts{ii}).identity, repmat(contrast_identity.(contrasts{ii})(jj), 1, numBins));
    end
    c.m.(contrasts{ii}).r1 = c.m.(contrasts{ii}).identity; 
    c.m.(contrasts{ii}).r2 = horzcat(zeros(1, length(c.m.(contrasts{ii}).identity) + numRegs), c.m.(contrasts{ii}).identity);
    c.m.(contrasts{ii}).all = horzcat(c.m.(contrasts{ii}).identity, zeros(1, numRegs), c.m.(contrasts{ii}).identity);
end
