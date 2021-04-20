# irvl
#### "INCIDENT RESPONSE VERKTYGS LÅDA"

## Introduction
["Bring Your Own Island"](https://www.fireeye.com/blog/threat-research/2020/11/live-off-the-land-an-overview-of-unc1945.html)
is all the fuzz. It's annoying to pop a box and find that not even the most basic utilities exist on the file system.
Bringing all your messy security tools and all the dependencies is a lot of work and a messy deal!
  
DrLove always thought [BusyBox](https://busybox.net/) was kind of cool - the argv 0 trickery is a nice hack.  
And sure, we could probably spend a lot of time to statically compile binaries and merge them together,
but besides the effort what about everything requiring Python and similar runtimes?  
  
I've previously packaged these sort of tools into [container images](https://github.com/Doctor-love/k8s_assessment_tools),
but these require a runtime and often root privileges to be executed. Ideally, I would like a container-esque statically
compiled binary that an unprivileged user could execute on ancient systems without fancy kernel features.  
  
Spoiler alert: I've not really succeeded with this, but have come somewhat close.  
  
There is a project called ["AppImage"](https://appimage.org/) which tries to develop a standardized way and tools 
to package Linux applications (and their dependencies) into a single executable. Think about it as Docker but 
without any runtime or sandboxing. By abusing features of the build tools, we can basically grab packages from 
a distros repository (Kali, for example) as "dependencies" and include a simple shell script to spawn the right
application based on provided argv 1.  
  
This is quite neat and actually seems to work:

```
$ ./hcvl-0.1-x86_64.AppImage hydra -h                 
Hydra v9.1 (c) 2020 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).
                                                               
Syntax: hydra [[[-l LOGIN|-L FILE] [-p PASS|-P FILE]] | [-C FILE]] [-e nsr] [-o FILE] [-t TASKS] [-M FILE [-T TASKS]] [-w TIME] [-W TIME] [-f] [-s PORT] [-x MIN:MAX:CHARSET] [-c TIME] [-ISOuvVd46] [-m MODULE_OPT] [service://server[:PORT][/OPT]]

[...]

$ ./hcvl-0.1-x86_64.AppImage strace --help                                                             
Usage: strace [-ACdffhikqqrtttTvVwxxyyzZ] [-I N] [-b execve] [-e EXPR]...
              [-a COLUMN] [-o FILE] [-s STRSIZE] [-X FORMAT] [-O OVERHEAD]                                                    
              [-S SORTBY] [-P PATH]... [-p PID]... [-U COLUMNS] [--seccomp-bpf]                                               
              { -p PID | [-DDD] [-E VAR=VAL]... [-u USERNAME] PROG [ARGS] }                                                   
   or: strace -c[dfwzZ] [-I N] [-b execve] [-e EXPR]... [-O OVERHEAD]
              [-S SORTBY] [-P PATH]... [-p PID]... [-U COLUMNS] [--seccomp-bpf]                                               
              { -p PID | [-DDD] [-E VAR=VAL]... [-u USERNAME] PROG [ARGS] }

[...]
```
  
AppImage really wants [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) to work as intended, 
but there is hack to run AppImages without it if you need to:

```
$ ./hcvl-0.1-x86_64.AppImage --appimage-extract-and-run curl https://ifconfig.co

82.202.189.138
```
  
So that's about it until I come up with something better!  
It's a bit less self-contained than a baked VM runtime + image, but there is something said for
sharing the host kernel and file system.  
  
**WARNING:**  
I'm a bit scared about the AppImage build tools, they do some funky stuff like bundle 
pre-built binaries which are curl'ed from their Github. Consider this more of a PoC than something 
to drop on sensitive hosts. And as always, _you_ are responsible for your actions.  


## Building
To keep things somewhat clean, the AppImage is built in a container.  
The following steps can be used with both Docker and [Podman](https://podman.io/):  

```
$ docker build --tag hcvl-builder:latest --build-arg BUILD_UID=$(id -u) .
$ docker run --rm --volume "${PWD}:/data" hcvl-builder:latest
```
  
If the commands above execute successfully, you'll have an ELF called 
"hcvl-0.1-x86_64.AppImage" in your working directory.  
  
The "appimage-builder" tool supports cross-building for ARM, but I've not tried this.


## Extending
Almost all of the sauce exist in "AppImageBuilder.yml" - take a look over there.
