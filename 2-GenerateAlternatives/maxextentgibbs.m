function [X] = maxextentgibbs(p,A,b,options)
% Draw from the uniform distribution over a convex polytope define by the constraint equations Ax <= b. Draws by cycling through 
%   each coordinate direction (decision variable), identifying the current
%   maximum extents of the variable, uniformly drawing a value within the
%   identified range, and continuing to the next coordinate. This progression mimics the Monte Carlo Marko Chain Gibbs method
%   (i.e., cycle through dimensions and use the previously sampled point as the starting point for the next sampled point).
%
%  OUTPUTS
%   X = a p-by-n matrix of random row vectors drawn
%        from the uniform distribution over the interior of the polytope
%        defined by Ax <= b.
%
%  INPUTS
%   p = number of points to sample
%   A = an m-by-n matrix of constraint equation
%        coefficients that includes both inequality, lower, and upper bound
%        constraints.
%   b = a m-by-1 vector of constraint equation constants.
%   options.x0 = an optional arbritrary starting point. Default is corner
%       point that minimizes x1 generated by linprog
%   options.extmethod = method used to find the extends. There are two options
%      opt = by optimization (default)
%      linalg = by linear algebra (doesn't work)
%   options.Algorithm = the algorithm used to solve the underlying LP
%       problems. See linprog.m for options. Default is not specified and uses Matlab's default.
%    
%   The maximum extent method works as follows:
%    1. Start with the first decision variable (x1). Solve 2 optimization
%    problems to find both the maximum and minimum values of x1 that
%    satisfy Ax <= b. i.e.:
%
%       Max x1                      Min x1
%       such that Ax < b    and     such that Ax < b
%
%       to get x1(-) and x1(+). Both problems are solved here with
%       lingprog.
%
%    2. Uniformly random sample in the range [x1(-), x1(+)]. This becomes
%    the sample value x1*
%
%    3. Now solve two 2 optimization problems to find both the maximum and
%    minimum values of x2 that satisfy Ax <= b with x1 = x1* (as in step 1).
%    Uniformly random sample in the range [x2(-), x2(+)]. This becomes
%    the sample value x2*
%
%    4. Repeat onward for x3 (with x1* and x2*), x4 (with x1*, x2*, x3*),
%    etc. until all xn are sampled. (x1*, x2*, ..., xn*) is the sampled
%    value
%
%
% CALLED FUNCTIONS
%    lingprog.m
%
%% #####################
%   Programmed by David E. Rosenberg
%
%   Dept. of Civil & Env. Engineering and Utah Water Research Lab
%   Utah State University
%   david.rosenberg@usu.edu
%
%   History
%   - March 22, 2013. First version.
%   - Modified July 2014 to test the validity of the starting point x0 against
%       the constraint set and if invalid or not specified, more reliably generate this starting point
%       from a single optimization.
%
%   David E. Rosenberg (2015) "Blended near-optimal alternative generation, 
%   visualization, and interaction for water resources decision making".
%   Water Resources Research. doi:10.1002/2013WR014667.
%   http://onlinelibrary.wiley.com/doi/10.1002/2013WR014667/full

%   LICENSING:
%   Copyright (c) 2014, David E Rosenberg
%   All rights reserved.
%
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are met:
%
%   * Redistributions of source code must retain the above copyright notice, this
%     list of conditions and the following disclaimer.
%
%   * Redistributions in binary form must reproduce the above copyright notice,
%     this list of conditions and the following disclaimer in the documentation
%     and/or other materials provided with the distribution.

%   * Neither the name of the Utah State University nor the names of its
%     contributors may be used to endorse or promote products derived from
%     this software without specific prior written permission.
%
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   Bug Reports and Feedback:
%   This code is possibly laden with bugs so bug reports and feedback are much appreciated. Please submit via the the issue tracker on the
%   GitHub repository where you downloaded this file.
%   Note, that while much appreciated, there is no promise of when--or if--the bug will be fixed.
%
%% #######################

    n = size(A,2);                         % dimension
    m = size(A,1);                         % num constraint ineqs
    
    % Check input arguments
    
    if m < n+1                             
        % obv a prob here
        error('cprnd:obvprob',['Only ', num2str(m), ' inqequalities. At least ',num2str(n+1),' inequalities ' ...
                            'required']);
    end
    
    %determine the extent method to use
    %lower(options.extmethod);
    if (nargin == 4) && (isstruct(options)) && isfield(options,'extmethod') && strcmp(lower(options.extmethod),'linalg')
        extmethod = 'linalg';
    else
        extmethod = 'opt';
    end

    %set up the output matrix
    X = zeros(p,n);
    %set up the extents and sampled values matrix; row 1 - min; row 2 -
    %max; row 3 - sampled value
    mExt = zeros(3,n);
    
    %Set up the options structure to use when calling linprog
    LPOptions = struct('maxiter',3000,'Display','off');
    %Read in the optional Algorithm parameter
    if (nargin==3) && (isstruct(options)) && isfield(options,'Algorithm')
        LPOptions.Algorithm = options.Algorithm;
    else
        LPOptions.Algorithm = 'interior-point';
    end
    
       
    %read in the initial starting point, if present
    x0 = [];           
    if isstruct(options) && isfield(options,'x0')
        % initial interior point
        x0test = options.x0;
        %Test that this point is feasible
        if length(x0test) == n
           %x0 must be in column vector form
            [xM xN] = size(x0test);
            if xN>1
                x0test = x0test';
            end
            %Count the number of constraint violations
            if sum(A*x0test > b) == 0
                x0 = x0test;
            end
        end  
    end
    if isempty(x0)
        %We should auto-generate an initial point
        %x0 = maxextent(1,A,b); %just need one seed point, any will do % didn't work very well
        i=1;
        [x0, fVal, fExitFlag minoutput] = linprog(circshift(eye(n,1),i-1),A,b,[],[],[],[],[],LPOptions); %just need one seed point, any will do
        while (fExitFlag ~= 1) && (i<=n)
            sprintf('i: %d, flag: %d, error: %s',i,fExitFlag, minoutput.message)
            i=i+1;
            [x0, fVal, fExitFlag minoutput] = linprog(circshift(eye(n,1),i-1),A,b,[],[],[],[],[],LPOptions); %just need one seed point, any will do
        end   
        if fExitFlag < 1
            warning('Could not generate an initial point')
            X = [];
            return
        end
    end
        
    %Loops through the random points   
    for i=1:p
        j=1;
        mExt(:,2:end) = 0;
        
        %start from the prior point. Mimicing the Monte-Marlo Markov Chain
        if i==1
            xprev = x0;
        else
            xprev = X(i-1,:)';
        end
        
        while j<=n % Loop through the coordinate directons (decision variables) -- Steps 3 and 4 on the 2nd, 3rd, etc. pass
           %Step 1. Solve 2 optimization problems to find both the maximum
           %and minimum values of xj that satisfy Ax <= b and x(1..n) =
           %previously found values for all dimensions ~= j.
           %Create the vector of cost coefficients representing the
           %decision variable value to optimize          
           %
           f = 1;
 
               xprev(j) = 0;
               
               try
                Bmod = b - A*xprev; %sometimes gives errors
               catch
                  [j] 
               end
                             
               switch (extmethod)
                 case 'linalg' 
                       %we don't need to optimize, instead just search for the
                       %min and max constraints
                      Ccurr = Bmod./(A(:,j));
                      fmin = max(Ccurr(A(:,j)<0));
                      fmax = min(Ccurr(A(:,j)>0));
                      fmaxexitflag = 1; fminexitflag = 1;
                  case 'opt'
                      %f = circshift(eye(n,1),j-1);
                      %f = eye(n-j+1,1);
                      f=1;
                      Amod = A(:,j);
                                          
                      [xmin, fmin, fminexitflag] = linprog(f,Amod,Bmod,[],[],[],[],[],LPOptions);
                       [xmax, fmax, fmaxexitflag] = linprog(-f,Amod,Bmod,[],[],[],[],[],LPOptions);
                       fmax = -fmax; 
               end
                                      
           
           %Step 2. Uniformly random sample within the fmin..fmax range
           if  (j==1) || ((fmaxexitflag>0) && (fminexitflag>0))
               %sprintf('p: %d, j: %d, fmin: %d, fmax: %d, min flag: %d, max flag: %d',i,j,fmin,fmax,fminexitflag, fmaxexitflag)
 
                xprev(j) = fmin + (fmax-fmin)*rand;

                mExt(1,j) = fmin;
                mExt(2,j) = fmax;
                
                mExt(3,j) = xprev(j);
                j=j+1;
           else
               %Optimization had errors, print to command window for help
               sprintf('p: %d, j: %d, fmin: %d, fmax: %d, min flag: %d, max flag: %d',i,j,fmin,fmax,fminexitflag, fmaxexitflag)
               %mExt
               %[Amod Bmod]    
               xprev(:) = NaN;
               j = n+1;
           end
        end

        X(i,:) = xprev(:);
    end      
 end
