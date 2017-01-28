extensions[array]

breed [fishes fish] ;fishes
breed [hunters hunter] ;hunters


to haltcondition  ;executes if count of fishes reaches to 0 .ie. when all fishes die
  if count fishes  = 0
  [stop] ;stop indicates end of plotting
end

globals [ ;available to every fucntion
  victims ;the fish that will be killed
  angle-head ;the moving angle of the turtles
  is-fish ;flag variable to check if it is fish
  is-hunter ;flag variable to check if it is a hunter
  safedistance ;distance that keeps fishes safe from the hunter
     agefactor ;the factor by which randomly created fishes are given their size and number of years
    count-of-fish-deaths  ;gives the death count of fishes
   e-mean   ;gives out the mean of energy of hunters
    present ;a flag variable
     da ;a flag variable
    reserve-strecth ;a flag variable
    mates ; to check if fishes are nearby
    y ;a flag variable

  reproduce ;a flag variable
  distribute;a flag variable
   dist ; to calculate the distance among turtles
    ]
to moverightbyt ;moves the calling turtle towards right by angle-t
  rt angle-t
end
to moveleftbyt ;moves the calling turtle towards left by angle-t
  lt angle-t
end

patches-own [ ;specific to patch
    food-source ;patches itself are taken as food source for fishes
    reserve; set a reserve of fuel for hunters when there are no fishes to hunt i.e. when hunters run out of energy
    ]
to setreserve

    ask n-of 50 patches[ set pcolor red
      let res patches in-radius 2.0
     ask res[ set reserve present ]]

end


to setageandsize ;to randomly set nummber of years and it's size according to it
   set num-of-years random 3  ;setting fish's age randomly->ranges from 0 to 200
 set size num-of-years * 1.0
        ;setting size of the fish according to it's age randomly
end


turtles-own [ ;specific to turtles(fishes, hunters)
    ELevel ;Energies
    myspeed ;Moving speed
     angle-t ;angle of deflection(fishes)
     energy-b ;energy level that the fishes have when they were created
    num-of-years ;this is randomly generated
   ]

to setup

 clear-all
 set y false
  set safedistance 0.2 ;(variable);setting the safe distance to 0.2
   set present 1
    create-fishes fish-population [ ;creating fishes
        setcoord         ;setting the coordinates in a random fashion
        set is-fish true ;setting the
        set is-hunter false ;boolean values for execution according to logic
        setspeedandenergies ;setting speeds and energies initialy
        setturnandmoveangles ;setting escape angle and heading angles

        set color pink   ;setting it's display color to pink(can be anything)

        set shape "fish"  ;setting shape of the turtle to fish to simualte a realsitic scenario

         setageandsize ;setting age and size accordingly and randoml


    ]

    repeat hunter-population [ create-hunters 1 [ ;create boats i.e. hunters
            setangle                ;setting the heading angle rndomly->ranges from  0 to 360 degrees
            setcoord   ;setting the hunter's display coordinates  in a random manner
setturnandmoveangles   ;setting the angles at which they move
            set shape "boat" ;setting shape of hunter to boat for it to be realistic
              set size 4 ;setting display size of the boat
 set is-fish false        ;setting the boolean values
        set is-hunter true
           setspeedandenergies;setting speed and energies of all the hunters initially
            set color yellow ;setting the color of hunter i.e. boat
    ]
       ]
    setfoodsource ;creating the food source

    set reproduce false ;setting
   set distribute true ;boolean values
    distributefood  ;foodsource needs to uniform


setinitialvalues ;all the initialisations are done here

  create-reserves  ; creation of fuel reserve
  reset-ticks
end
to create-reserves  ;this methods creates  reserve at the center of the screen

  ask  patch 0 0  [ set pcolor red]
   ask patch 0 1[set pcolor red]
  ask patch -1 0[set pcolor red]
   ask patch -1 1[set pcolor red]

end


to go
 reproduce-food ;each and every time food gets generated
  setfood
     create-reserves ;creating reserves
 ifelse(not pollution?)[ ;above all the other conditions it checks if pollution is sensed
 ask hunters [ifelse ( fishing-season? and ( not badweather?))[
         ;if both are true then we see if hunting is allowed
      ifelse(Option-Hunt and (not pollution?))[
           show-turtle ; if both are true then hunters are allowed
         attack] ; and they can attack the fishes
        [  set count-of-fish-deaths 0
          set Option-Hunt false
          set ELevel ELevel - 1;as they don't hunt, each time they move their energy will be reduced
          set e-mean abs( sum [ELevel] of hunters ) ;mean of the hunter's energy is nothing but sum of every other hunter energy
          fd 5  ;boats just move as hunting is not allowed
            ]
        ]   [
        hide-turtle
        set e-mean abs( sum [ELevel] of hunters )
        ask fishes [

        set count-of-fish-deaths 0  if (ELevel > energy-b) [ ;always we check if it's energy is still good to be alive
        fishreproduce ]]]];if fishing-season is not on boats are not allowed to hunt,so we hide them

    ask fishes [ ;if not sensed, we jut set the color to pink
      set color pink
        set ELevel ELevel - 1 ;we decrease the energy of the fish for every move
       ifelse ((any? hunters in-radius 1) and Option-Escape );now we check if any of the fish is in the view zone of hunters and also check if escape option is on
          [set angle-t 42 ;can be varied ;if both are true then we set the global var angle-t ->it turns with that angle
            fd espeed                   ;after turning away it moves forward with it's escaping speed which can be varied using sliders
            set ELevel ELevel - espeed / 3 ];as it turns/escapes it's energy is reduced
           [ checkifitcanhunt
             set Elevel Elevel - 2] ;check if hunting is allowed
         if (food-source > 1) [ ;checks if food is still avaliable
        set ELevel ELevel + 3 ;if so fish when they eat them increase their energy
        set food-source food-source - 1 ;foodsource will be simulatneously reduced
        ] ]

      ask fishes [  if (ELevel > energy-b) [ ;always we check if it's energy is still good to be alive
        fishreproduce ]]; otherwise fish needs to be born again

   ]
 ;else case if the water is not polluted

 [ ask fishes[set color red    ; all the fishes turn red as an indiacation of the water being polluted
     set count-of-fish-deaths fish-population ;all the fishes will die-> count of deaths will be the total number of fishes
     die]     ;they die
 ;each time we check if fishes count is 0 or deaths are not recorded ;if any of it is true-> it means hunting is not allowed.So, the hunters go to the reserve
     if ( (count fishes = 0)  or (count-of-fish-deaths = 0) )[ask hunters [gotoreserve]]]
 ;even if the fishes turn red->all of them are exposed to pollution,hunters have no fish t hunt-> again they seek the reserve to gather and get refuelled.
 if all? fishes [color = red] [ask hunters [gotoreserve]]
  ;we will check if fishing season is on and also check if no calamities are sensed


;if mean of energy drops below 0 for hunters
 if(e-mean <= 0)[ask hunters[
      if any? patches with [pcolor = red][move-to patch-here ;send those hunters boats to reserve to refuelise
        set Elevel  500 ;energy levels are reset and again they attempt to attack
    ;attack
    ] ] ]

    set-current-plot "EnergyLevel"  ;plotting the energies of the fishes and hunters
    set-current-plot-pen "ELevelHunter"
    plot sum [ELevel] of hunters
    set-current-plot-pen "ElevelFish"
    plot sum [ELevel] of fishes

   haltcondition  ;plotting stops if  count of fishes becomes 0

    tick
end
to gotoreserve  ;moving the fishes to this patch i.e the reserve
if(any? patches with [ pcolor = red])[

  move-to  patch 0 0
  ask hunters[set color blue fd 1  ] ;hunterboats turn blue when they are refuelised
  user-message("No fishes");system halts as no fishes are there to hunt

  ]

end
to gotoreserveandattack   ;same method as gotoreserve but attacking is also added so hunters get their energy reduced
 if(any? patches with [ pcolor = red])[

  move-to  patch 0 0

 set color blue
  rt  random 50;executes when a fish tries to escape from the hunter
   lt random 50
    fd myspeed
   set ELevel ELevel - myspeed * 2  ;reducing it's energy
  attack
  ]
end
to setangle ;setting the angle by which the fishes head forward randomly
  set angle-head  360 ;can be varied
end
 to setspeedandenergies
   if(is-fish)
    [set myspeed 2 ]   ;setting it's moving spped to 1
    if(is-hunter)
    [set myspeed 1]
    set energy-b 50   ;setting fish's energy-b to 25
        set ELevel 100  ;setting fish's energy level randomly->ranges from 0 to 100

 end




to setcoord ;seting the display coordinates of the fishes, hunters
   setxy random-xcor random-ycor
end

to setfood
     ask patches [

    set pcolor  blue  ; the food source will be created on the  patches

   ]
end


;hunterboat's procedure
to attack

    ifelse ( any? fishes in-radius 1 ) ;else if they aren't in a safely marked patches and if they are preys
        [  set victims  fishes in-radius 1.5 ;if they are in a radius of 2 they will be considered to be killed
          ifelse any? victims  ;check f they are victims
           [ kill]
              [ ifelse ( Option-Hunt or fishing-season?)
                  [set da false
                     setvictim any? fishes in-radius 1
                     set dist distance myself
                      ifelse (da)[
   let a   ((towards victims) + 90) - angle-head
    checkmovingdirection a]
 [  let a  towards victims - angle-head
   checkmovingdirection a ]
                    fd hspeed
                    set ELevel ELevel - hspeed * 2 ]
                  [
  rt  random 50;executes when a fish tries to escape from the hunter
   lt random 50
    fd myspeed
   set ELevel ELevel - myspeed * 2  ;reducing it's energy
]
               ]
        ]


        [
  rt  random 50;executes when a fish tries to escape from the hunter
   lt random 50
    fd myspeed
   set ELevel ELevel - myspeed * 2  ;reducing it's energy
 ]


end




to setfoodsource
  ask patches [ set food-source random 10 ] ;setting the food source randomly on the patches

end

to setinitialvalues

    set count-of-fish-deaths 0;setting the count to 0 initially
    set e-mean 0 ;setting the mean of enrgies to 0 initially
end

to setturnandmoveangles


   set angle-t 10  ;setting it's angle-t to 10
end

to reproduce-food
   ask patches [
       if (food-source < 1) [  ;check if food source is decreasing to some level

           set food-source food-source  + 1 ;if so keep increasing or reproducing the food source
           ]
       ]
   set reproduce true
   set distribute false
   distributefood ;uniformly distribute the reproduced food source
end

to fishreproduce
 repeat 1[hatch 1 [
           set ELevel energy-b
           setangle
           fd myspeed ] ]
end

  to checkmovingdirection [a]
    ifelse (abs (a) > angle-t)
                  [ ifelse a > 0 [moverightbyt] [moveleftbyt] ]
                  [  rt a ]
  end
  to kill
                   let s count victims
                 set ELevel ELevel + sum [ELevel] of victims / 2

                set count-of-fish-deaths count-of-fish-deaths + s;the count of deaths of fishes will be incresed with the count of victims
                ask n-of (s) victims [die] ;those victime will be dead
                 set e-mean  abs(e-mean + sum [ELevel]  of hunters )
  end
  to distributefood
    if(distribute)
    [ repeat 5 [diffuse food-source 1 ] ];uniformly distribute the food source over the patches and the distribution is 100%
     if(reproduce)
     [diffuse food-source 1]

  end
  to checkifitcanhunt
           ifelse( not (Option-Hunt))
             [ask fishes[ set count-of-fish-deaths 0
                  rt  random 50;executes when a fish tries to escape from the hunter
   lt random 50
    fd myspeed
   set ELevel ELevel - myspeed * 2 ]] [ rt  random 50;executes when a fish tries to escape from the hunter
   lt random 50
    fd myspeed
   set ELevel ELevel - myspeed * 2  ;reducing it's energy
   ];we also check if gathering option is on.If so we gather all the fishes or else we move them

  end

  to setvictim[x ]
    set victims min-one-of x [dist]
  end
@#$#@#$#@
GRAPHICS-WINDOW
309
10
729
451
20
20
10.0
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
761
10
841
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
33
146
66
fish-population
fish-population
0
100
64
1
1
NIL
HORIZONTAL

BUTTON
968
10
1024
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
56
429
142
474
Fishes_count
count fishes
3
1
11

SLIDER
172
32
296
65
hunter-population
hunter-population
0
20
10
1
1
NIL
HORIZONTAL

SWITCH
766
97
907
130
Option-Hunt
Option-Hunt
0
1
-1000

SWITCH
6
140
147
173
Option-Escape
Option-Escape
0
1
-1000

SLIDER
164
141
289
174
espeed
espeed
0
4
2.7
0.1
1
NIL
HORIZONTAL

SLIDER
166
183
293
216
hspeed
hspeed
0
10
2.6
0.1
1
NIL
HORIZONTAL

MONITOR
197
318
293
363
NIL
e-mean
3
1
11

MONITOR
182
373
309
418
NIL
count-of-fish-deaths
3
1
11

PLOT
740
244
1005
434
EnergyLevel
NIL
NIL
0.0
20.0
0.0
10.0
true
true
"" ""
PENS
"ELevelHunter" 1.0 0 -16777216 true "" ""
"ElevelFish" 1.0 0 -2674135 true "" ""

SWITCH
-1
92
140
125
fishing-season?
fishing-season?
0
1
-1000

BUTTON
880
10
943
43
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
174
248
302
281
badweather?
badweather?
1
1
-1000

SWITCH
21
248
129
281
pollution?
pollution?
1
1
-1000

@#$#@#$#@
Fishing was one among the occupations of so many people who live nearby water bodies. Fishing if done without any rules and regulations will definitely have a huge impact on the fish ecology. If such situation occurs, there will a dire need to control hunters from doing so by introducing concepts called fishing season. This highly reduces the death rate of fishes and maintains a balanced environment.


This model is based on the fish being affected by the hunters and also the hunting being influenced by the environmental changes, whether it is a fishing season or not. This model is entirely different from all other predator-prey models. In other models, the predators just go on hunting no matter what. Unlike them, in this model, we have several scenarios where in a fisher can hunt only if and only if it is a fishing season and hunters prefer to hunt. This models considers another situation where some natural calamities occur and hunters can’t fish. This is modelled in a switch named bad-weather. If bad-weather is on that means calamities are sensed. Fishes can escape from the hunters when they are within the premises of the hunters if and only if escaping is allowed. Above all, Pollution has also been taken into consideration. If pollution is sensed, then no matter what, all the fishes die.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

boat
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

minnow
true
0
Polygon -7500403 true true 150 15 136 32 118 80 105 90 90 120 105 120 115 145 125 208 131 259 120 285 135 285 165 285 150 261 167 208 177 141 180 120 195 120 195 105 178 80 162 32

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

shark
true
0
Polygon -7500403 true true 150 15 164 32 182 80 204 98 210 113 189 117 185 145 175 208 169 259 200 277 168 276 135 298 150 261 133 208 123 141 123 116 99 123 104 106 122 80 138 32

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
