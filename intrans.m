function [ g ] = intrans( f, method, varargin )
%intensity(gray-level) transformations
%  f: the input image
%  method:  
%         intrans(F,'neg'):compute the negative of input image

%         intrans(F,'log',C,CLASS):computes C*log(1+F), C default 1, CLASS
%               decides the output as 'uint8' or 'uint16',default is the same
%               class as the input.

%         intrans(F,'gamma', GAM):gamma transformation,GAM is required
%               input

%         intrans(F,'stretch',M,E):contrast-stretching transformation,using
%               expresstion 1./(1+(M./F).^E).M must be in the range
%               [0,1],the default value for M is mean2(tofloat(F)),and the
%               default value for E is 4.
%       
%         intrans(F, 'specified', TXFUN): s = TXFUN(r), s is the out
%               intensity, r is the input intensity, TXFUN is an intensity
%               transformation,expressed as a vector with values in the
%               range [0,1]. TXFUN must have at least two values.
%
%          if the values of input images are outside the range[0,1] are
%          scaled first using MAT2GRAY. other are converted to floating
%          point using TOFLOAT.


%check the inputs
narginchk(2,4);

if(strcmp(method, 'log'))
    g = logTransform(f,varargin{:});
    return;
end

if isfloat(f) && (max(f(:)) > 1 || min(f(:)) < 0 )
    f = mat2gray(f);
end

[f, revertclass] = tofloat(f);

switch method
    case 'neg'
        g = imcomplement(f);
        
    case 'gamma'
        g = gammaTransform(f,varargin{:});
        
    case 'stretch'
        g = stretchTransform(f,varargin{:});
        
    case 'specified'
        g = specifiedTransform(f,varargin{:});
        
    otherwise
        error('Unknown enhancement method.');
end

g = revertclass(g);

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function g = gammaTransform(f,gamma)
g = imadjust(f, [ ], [ ], gamma);
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %      

function g = stretchTransform(f, varargin)
if isempty(varargin)
    m = mean2(f);
    E = 4.0;
elseif length(varargin) == 2
    m = varargin{1};
    E = varargin{2};
else
    error('incorrect number of inputs for the stretch method.');
end

g = 1 ./ ( 1 + ( m ./f ) .^ E );

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

function g = specifiedTransform(f,txfun)
txfun = txfun(:);  %force it to be a column vector
if any(txfun) > 1 || any(txfun) <= 0
    error('All elements of txfun must be in the range[0,1].')
end

T = txfun;
x = linspace(0,1, numel(T))';
g = interp1(x,T,f);

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

function g = logTransform(f, varargin)

[f, revertclass] = tofloat(f);
if numel(varargin) >= 2
    if strcmp(varargin{2}, 'uint8')
        revertclass = @im2uint8;
    elseif strcmp(varargin{2}, 'uint16')
        revertclass = @im2uint16;
    else
        error('Unsupported CLASS option for "log" method.')
    end
end

if numel(varargin) < 1
    
    C = 1;
else
    C = varargin{1};
end
g = C * ( log(1+f) );
g = revertclass(g);

end


