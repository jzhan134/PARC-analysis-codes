1. Trajectory tracking

	1.1 Experimental background:

		Electrophoresis is the particle motion in an electric field due to the interaction of the field 
		and the surrounding charges near the particles. The velocity of particle is proportional to the
		field magnitude, and the ratio depends on the particle and medium properties.

		Oxidized particle (currrently alumina with 10um diameter) moving in non-aqueous envoironment 
		(currently hexadecane with AOT as additive) is studied to understand the influence of 
		non-aqueous medium and the addition of additives to the particle surface charges and mobility. 
		A parallel electrode is fabricated to create the electric field, in which the particles are 
		moved accordingly. The motion can be visualized under an inverted microscope, in which the 
		particles can be seen as having a bright center and a dark rim. A digital camera is attached to 
		the microscope, and the motion is recorded at a certain frame rate for a manually set period of
		time.

	1.2 Experimental data collection:

		Multiple video clips will be recorded and saved for a single field type (frequency, magnitude, 
		and signal type). These files are saved using the following name format:
											  aV_bHz_c.avi
		where a is the field magnitude shown on the function generator, which is amplified by 40 times
		when used on the electrode; b is the frequency of the field, which could be different from the
		frequency captured by the video due to the different frame rate of movie and camera capture; c
		is the appendix to distinguish between different files under same condition, and Roman letters
		are normally used. This name format applies to the experiments using square signal, and when
		sinuosoidal signal is used, the name format is:
											  aV_bHz_sin_c.avi

	1.3 Data processing and code algorithm:

		The script converts up to 10 particles' motions under the same condition into displacement 
		trajectories. These particles can be selected from different files or different time period
		within each file, so long if their conditions are same (field frequency and magnitude). The
		detailed algorithm is as follow.

		The script first identify the condition of the experiment, i.e. the freuqency and amplitude
		automatically from the file name. The code then requires an manual select of the
		appendix to load the corresponding video file, and an assignment of particle index number to 
		save the trajectory. A data file is created for each experiment condition, in which each 
		particle is saved as an separate entry with the following information:
		  1. Video_idx: the video source (appendix) of the current particle;
		  2. Trajectory: the displacement of the particle measured from the edge of the eletrode;
		  3. Trajectory_Movie:  the displacement of the particle measured from the edge of the screen

  	1.4 Current constrains:
	
		Particles should has significant contrast to the background brightness
		Particle being tracked should be at least a particle-radius away from any other particle in 
		any frame
		At least one side of the electrode edge has to be identifiable
