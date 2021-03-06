Documentation-readme.txt

The Documentation folder contains the script files and specific directions to generate each figure in the print version of the article. Additionally, the folder has the final accepted version of the manuscript, slides from a presentation at the European Geophysical Union conference in April 2015, and a folder containing earlier drafts of the manuscript, reviewer comments, and response letters to reviewer comments through 4 rounds of peer-review.

Rosenberg-2015Feb-BlendedNearOptimalTools.pdf : Final version of the manuscript submitted in February 2015 and accepted for publication. Final, open access published version available at http://dx.doi.org/10.1002/2013WR014667.

Rosenberg-NearOptimal-EGU-2015.pptx : Slides for a power-point presentation on Near-Optimal made at the European Geophyscial Union annual conference in April 2015.

LoadYourOwnModel.m : Directions and example for how to load your own model data into the near-optimal tools. Specific directions for linear programs, more general directions for mixed-integer programs.

NearOptimalManagement-Lab.pdf : Step-by-step directions and instructions to use the near-optimal tools in a computer lab activitity (approximately 2-hours). 

Within the ScriptsForPaper folder:

- Fig_GenForNearOptPaper.m : Matlab script to use to generate Figures 1, 2, 3, and 5 in the revised paper. To run this script, you must download all files in the AlternativeGeneration, InteractiveParallelPlot, and EchoReservoirApplication folders. In Matlab, add the folder and all sub-folders where you downloaded the files to your Matlab path, set the Matlab directory to the subfolder /4-EchoReservoirApplication, and enter the following command at the Matlab command prompt:

	>> Fig_GenForNearOptPaper

The file also has additional directions to interactively generate Figures 4, 5, 6, and 7 from Figure 3 as comments in the .m file. Figure 5 can also be automatically generated.

The file also contains the commands and directions to generate all the results that are discussed in the manuscript but not presented.

- Fig1_FeasibleNearOptCompare.m : Matlab script to generate Figures 1 and 2 in the revised paper. See Fig_GenForNearOptPaper.m for the parameter settings used for the paper figure.

- doMGA.m : a Matlab file that includes the logic for generating alternatives by various MGA methods. Used to generate Figures 1, 3, 4, 5, and 6.

- Delcols.m, extrdir.m, extrpts.m, polygeom.m : other Matlab files used by the above scripts.

Within the ManuscriptDrafts folder:

- Rosenberg-2015Feb-ResponseLetter3-BlendedNearOptimalTools.pdf : Letter listing reviewer comments, author responses and descriptions of changes made in the Feb, 2015 version of the paper to address the comments.

- Rosenberg-2014Dec-BlendedNearOptimalTools.pdf : revised version of the manuscript re-submitted to Water Resources Research in Dec 2014 that addresses 2nd round of reviewer comments.

- Rosenberg-2014Aug-BlendedNearOptimalTools.pdf : revised version of the manuscript re-submitted to Water Resources Research in August 2014 that addresses 1st round of reviewer comments.

- Rosenberg-2013Aug-BlendedNearOptimalTools.pdf : original version of the manuscript submitted in August 2013 to Water Resources Research.

- Rosenberg-2014Dec-ResponseLetter2-BlendedNearOptimalTools.pdf : Letter listing reviewer comments, author responses and descriptions of changes made in the Dec, 2014 version of the paper to address the comments.

- Rosenberg-2014Aug-ResponseLetter1-BlendedNearOptimalTools.pdf : Letter listing reviewer comments, author responses and descriptions of changes made in the August, 2014 version of the paper to address the comments.