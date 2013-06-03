Dart Flight
========

Dart Framework Light - an approach to a most basic IOC framework to faciliate dart projects.

Disambiguation: Flight refers to dart flight, not to a bird's flight, and it has no connection whatsoever to the Twitter Flight framework. 


Credits
--------
My work on this project is kindly supported by [i-edit Inc.]{i-edit.ca}.


Introduction
------------

Idea of this project is to provide a lightweight(!) IOC and MVC framework to help in managing dart projects.
It intends to have an easy to understand small API and low overhead, as well as in code as in performance.
Since this is work in the initial design stage, comments and suggestions are welcome.

Why IOC, when we have factory constructors?
--------------------
In discussions the topic about the need (or advantages) of IOC is often touched, most of the time with the argument:
"Why do we need that if we have factory constructors?"

Well, though i am pretty fond of the factory and named constructors and what they can provide, i don't see why they should
make a design pattern like IOC obsolete. I rather look for ways to integrate the options into IOC.
That said, i still wait for a decisive answer on HOW factory constructors are the solution to everything IOC is aiming at.

Well, what is it that IOC is aiming at anyways?
-----------------------------

Can't give a final answer to that without sounding religous, but THIS framework aims at providing a central point in projects to configure the wireup of classes, in mid to long term providing aid
in structuring projects and keeping them maintainable. 
I currently don't plan for extensive auto wiring, since i do not believe that the small savings in code compensate the obfuscation effect this can have
on participants collaborating on a project they do not know from the start.

Roadmap
-------

- Architectural IOC definition
- Context design
- IOC implementation
- Scope definition for MVC support
- MVC pattern definition
- MVC implementation
- Helper library
