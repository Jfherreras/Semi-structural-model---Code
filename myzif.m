function Y = myzif(X,varargin)

% {
Y = (1 + erf(3*X))/2;
Y = Y .* X;
% }

%{
if isempty(varargin)
    Y = X;
    Y(X < 0) = 0;
    return
end

if length(varargin) == 1
    Y = true;
    return
end

if length(varargin{2}) == 1
    Y = X;
    Y(X >= 0) = 1;
    Y(X < 0) = 0;
    return
end

if length(varargin{2}) == 2
    Y = X;
    Y(:) = 0;
    return
end
%}

end