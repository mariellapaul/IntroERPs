# IntroERPs

# About this project

In April 2018, I taught a class titled "A Hands-On Introduction to Event-Related Potentials" at the Berlin School of Mind and Brain. You'll find the code for this class here and I'll also share the slides in the future.

# Description of the class

Event-related potentials (ERPs) are a commonly used method in psychology, cognitive neuroscience and related fields. With their high temporal resolution on the order of milliseconds, ERPs allow insight into brain mechanisms involved in learning, language processing, social cognition, and many others. The aim of this course is to learn how to use ERPs to study the mind and the brain, to get hands-on experience with the analysis of ERPs, and to get intuitions about the underlying principles of analysis steps. There are no specific prerequisites needed for this course, although basic programming skills in Matlab will be advantageous.
	
We will start with a brief introduction of EEG data in general and specifically ERPs. We will learn which kind of research questions can be answered using ERPs and how to design an ERP experiment. We will also look at a number of ERPs commonly found in neuropsychological experiments and learn how to interpret them. Then, we will turn to the hands-on sessions, in which we will analyze EEG data using Fieldtrip, an open-source, Matlab-based toolbox. We will learn how to get from raw EEG data acquired in psychological experiments to ERPs. Using Fieldtrip, we will perform commonly used steps of EEG analysis, including filtering, segmenting, rereferencing, cleaning, averaging and plotting. As a final step, we will learn how to use statistical analysis on ERPs. For each of these steps, we will first look at the underlying principles and then conduct this analysis step ourselves.

# Structure of this repository

In this repository, you'll find the slides of this class as well as the code we used or developed during this class.

There are two main scripts for this class: matlab_programming_principles.m and eeg_analysis_pipeline.m. The slides and code titled Matlab programming principles were designed to give students not familiar with Matlab a very brief introduction to the programming principles needed for this course. The main part of this course was hands-on, where each student developed their own pipeline for EEG analyses. I've posted my solution here as eeg_analysis_pipeline. The rest of the code are functions called by eeg_analysis_pipeline.m.

# Creative Commons license

All of these materials are licensed under Creative Commons CC by-SA 4.0, which means you can share and adapt, as long as you attribute the source (in this case, me) and share alike and non-commercially. If you'd like to share or re-use these materials, please feel free do to so by attributing them to:

Mariella Paul "A Hands-On Introduction to Event-Related Potentials" [CC by-SA 4.0]

https://creativecommons.org/licenses/by-sa/4.0/legalcode

# Questions and Comments
If you have any questions or comments, please feel free to contact me under

paulm@cbs.mpg.de

This was the first time I've given this class and there are surely many things that could be improved and that I'd like to improve before teaching this class again. I'd be very grateful for any suggestions or constructive criticism you might have.
