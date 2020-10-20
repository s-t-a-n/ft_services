# ft_services

With the exception of the 'Load Balancer will have a single ip' requirement this ft_services passes every test. May it help you speed up this draconian and unhelpful project.

Some stuff I would have found helpful when starting ft_services:
- use supervisord (in Docker image) in combination with readinessProbe & livenessProbe (in yaml file) to guarantee the proper state of the containers (pods).
- don't try to setup a global file with cluster authentication (like i did). Just hardcode the living hell out of this project to protect your sanity.
