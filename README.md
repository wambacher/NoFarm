Introduction
============

NoFarm displays areas with landuse=farm, landuse=farmland and landuse=farmyard
using a Leafletjs-based OpenStreetMap-Map.

Author/Contact
==============

Walter Nordmann, aka wambacher wnordmann@gmx.de 


Installation
============

mvn clean compile package install

scp target/NoFarm.war SERVER:JETTY-DIRECTORY/webapps
