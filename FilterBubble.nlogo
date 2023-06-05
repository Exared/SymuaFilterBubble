turtles-own [
  friends                  ; Liste des amis de chaque agent
  belief                   ; Croyance de chaque agent
  id                       ; Id de chaque agent
]

to setup
  clear-all
  init-turtles                        ; Initialisation des agents
  create-visible-links                ; Creer des liens visibles entre les agents amis
  reset-ticks
end

to go
  move-towards-random-friend              ; Movement des agents
  show-graph-population                   ; Affiche les groupes d'agents ayant une certaine opinion majoritaire

  if ticks mod 20 = 0  and ticks != 0 [
    recommend-friends                     ; Recommande de nouveaux amis
    create-visible-links                  ; Update l'affichage des liens entre les amis
  ]
  if ticks mod 10 = 0 [
    update-opinion                        ; Update les opinions des agents
  ]

  if ticks = 1000 [display-friend-percentages stop]

  tick
end

to show-graph-population
  let red-turtles count turtles with [ dominant-belief belief = 0 ]
  let blue-turtles count turtles with [ dominant-belief belief = 1 ]
  let green-turtles count turtles with [ dominant-belief belief = 2 ]
  let yellow-turtles count turtles with [ dominant-belief belief = 3 ]

  ; Tracer les valeurs sur le graphique
  set-current-plot "population"
  set-current-plot-pen "Rouge"
  plot red-turtles
  set-current-plot-pen "Bleu"
  plot blue-turtles
  set-current-plot-pen "Vert"
  plot green-turtles
  set-current-plot-pen "Jaune"
  plot yellow-turtles
end

to init-turtles
  create-turtles num-agents [
    setxy random-xcor random-ycor    ; Position initiale aléatoire
    set shape "person"               ; Forme des agents
    set color white                  ; Couleur des agents
    set size 0.8                     ; Taille des agents
    set friends nobody               ; Initialiser la liste des amis

    set belief n-values 4 [random-float 1.0] ; Définir la croyance initiale de chaque agents de maniere aleatoire
    set id who
    if show-id [ set label id set label-color red ]
  ]

  ; Établir des liens d'amitié entre les agents
  ; On initialise des paires d'amis
  let unpaired-turtles turtles
  while [any? unpaired-turtles] [
    let turtle1 one-of unpaired-turtles
    set unpaired-turtles unpaired-turtles with [self != turtle1]
    if any? unpaired-turtles [
      let turtle2 one-of unpaired-turtles
      set unpaired-turtles unpaired-turtles with [self != turtle2]
      ask turtle1 [set friends (turtle-set friends turtle2)]
      ask turtle2 [set friends (turtle-set friends turtle1)]
    ]
  ]
end

; Creer des liens visibles entre les agents amis
to create-visible-links
  ask turtles [
    let my-friends friends
    create-links-with my-friends
  ]
end

; Return l'index de l'opinion la plus forte d'un agent
to-report dominant-belief [beliefs]
  report position max beliefs beliefs
end

; Set la couleur d'un agent selon son opinion la plus forte
to set-turtles-color
  let max-index dominant-belief belief
  if max-index = 0 [ set color red ]
  if max-index = 1 [ set color blue ]
  if max-index = 2 [ set color green ]
  if max-index = 3 [ set color yellow ]
end

; Se deplace vers un ami aleatoire
to move-towards-random-friend
  ask turtles [
    let friend one-of friends
    if random 2 = 0 [ face friend]

    fd movement-step
  ]
end

; on remplace l'opinion de chaque agent par son la somme ponderer entre son opinion et celle de ses amis
to update-opinion
  ask turtles [
    let total-weight 0 ; Variable pour stocker la somme des poids des amis
    let weighted-opinion (list 0 0 0 0) ; Liste pour stocker la somme pondérée des opinions des amis

    ; Parcourir les amis de l'agent
    ask friends [
      ; Effectuer la pondération de l'opinion de l'ami et l'ajouter à la somme pondérée
      set weighted-opinion map [x -> x * friends-influence] belief
    ]
    set belief (map [ [a b] -> a + b] belief weighted-opinion)
    set-turtles-color
  ]
end

; Recommandation d'amis differents de l'agent courant
to recommend-diversity [potential-friends]
  let current-turtle self                   ; Agent courant (pour lequel on veut recommander des amis)
  let my-belief dominant-belief belief      ; Opinion dominante de l'agent courant

  ask potential-friends                     ; On Iterate sur tous les potentiels amis
  [
    let their-belief dominant-belief belief ; On recupere l'opinion dominante du potentiel ami
    if (count friends < max-friend) and (count [friends] of current-turtle < max-friend)  [    ; On verifie que l'agent courant ET le potentiel ami non pas le nombre max d'amis atteint
      if their-belief != my-belief [                                                           ; Si leur opinion dominante est differente (car ici on veut diversifier les amis)
        set friends (turtle-set friends current-turtle)                                        ; On ajoute l'agent courant dans la liste d'amis du potentiel ami
        let potential-friend self
        ask current-turtle [
          set friends (turtle-set friends potential-friend)                                    ; On ajoute le potentiel ami dans la liste d'amis de l'agent courant
        ]
        stop                                                                                   ; On quit la loop apres avoir recommander le premier ami      ]
      ]
    ]
  ]
end

; Recommandation d'amis similaires a l'agent courant
to recommend-similarity [potential-friends]
  let current-turtle self                   ; Agent courant (pour lequel on veut recommander des amis)
  let my-belief dominant-belief belief      ; Opinion dominante de l'agent courant

  ask potential-friends                     ; On Iterate sur tous les potentiels amis
  [
    let their-belief dominant-belief belief ; On recupere l'opinion dominante du potentiel ami
    if (count friends < max-friend) and (count [friends] of current-turtle < max-friend)  [    ; On verifie que l'agent courant ET le potentiel ami non pas le nombre max d'amis atteint
      if their-belief = my-belief [                                                           ; Si leur opinion dominante est la meme (car ici on veut personnaliser les amis)
        set friends (turtle-set friends current-turtle)                                        ; On ajoute l'agent courant dans la liste d'amis du potentiel ami
        let potential-friend self
        ask current-turtle [
          set friends (turtle-set friends potential-friend)        ; On ajoute le potentiel ami dans la liste d'amis de l'agent courant
        ]
        stop      ; On quit la loop apres avoir recommander le premier ami
      ]
    ]
  ]
end

; Recommandation d'amis random
to recommend-random [potential-friends]
  let current-turtle self                   ; Agent courant (pour lequel on veut recommander des amis)
  let my-belief dominant-belief belief      ; Opinion dominante de l'agent courant

  ask potential-friends                     ; On Iterate sur tous les potentiels amis
  [
    let their-belief dominant-belief belief      ; On recupere l'opinion dominante du potentiel ami
    if (count friends < max-friend) and (count [friends] of current-turtle < max-friend)  [    ; On verifie que l'agent courant ET le potentiel ami non pas le nombre max d'amis atteint
      set friends (turtle-set friends current-turtle)                                          ; On ajoute l'agent courant dans la liste d'amis du potentiel ami
      let potential-friend self
      ask current-turtle [
        set friends (turtle-set friends potential-friend)       ; On ajoute le potentiel ami dans la liste d'amis de l'agent courant
      ]
      stop     ; On quit la loop apres avoir recommander le premier ami
    ]
  ]
end


;; Recommande un nouvel ami a chaque agent selon la strategie choisit
to recommend-friends
  ask turtles [
    let potential-friends other turtles with [not member? self [friends] of myself]     ; Les potentiels amis sont tous les agents qui ne sont pas l'agent courant et qui ne sont pas deja amis avec lui
    if random 2 = 0 [                                                                   ; On recommande des amis selon la strategy
      if strategy = "Similarity" [recommend-similarity potential-friends]
      if strategy = "Diversity" [recommend-diversity potential-friends]
      if strategy = "Random" [recommend-random potential-friends]
    ]
  ]
end


to-report compute-friendship [current-dominant-belief]
  let total-red 0
  let total-blue 0
  let total-green 0
  let total-yellow 0

  ; Parcourir tous les agents
  ask turtles with [dominant-belief belief = current-dominant-belief][
    let red-friends count friends with [ dominant-belief belief = 0 ]
    let blue-friends count friends with [ dominant-belief belief = 1 ]
    let green-friends count friends with [ dominant-belief belief = 2 ]
    let yellow-friends count friends with [ dominant-belief belief = 3 ]

    ; Ajouter les pourcentages d'amis à chaque couleur totale
    set total-red total-red + red-friends
    set total-blue total-blue + blue-friends
    set total-green total-green + green-friends
    set total-yellow total-yellow + yellow-friends
  ]
  report (list total-red total-blue total-green total-yellow)
end

to display-friend-percentages
  ; On recupere la liste des relations des differentes couleurs
  let red-relations compute-friendship 0
  let blue-relations compute-friendship 1
  let green-relations compute-friendship 2
  let yellow-relations compute-friendship 3

  ; On definit le nombres de liens d'amitie entre chaque couleurs
  ; cas rouge
  let total-red-red item 0 red-relations
  let total-blue-red item 1 red-relations
  let total-green-red item 2 red-relations
  let total-yellow-red item 3 red-relations

  ; cas bleu
  let total-red-blue item 0 blue-relations
  let total-blue-blue item 1 blue-relations
  let total-green-blue item 2 blue-relations
  let total-yellow-blue item 3 blue-relations

  ; cas vert
  let total-red-green item 0 green-relations
  let total-blue-green item 1 green-relations
  let total-green-green item 2 green-relations
  let total-yellow-green item 3 green-relations

  ; cas jaune
  let total-red-yellow item 0 yellow-relations
  let total-blue-yellow item 1 yellow-relations
  let total-green-yellow item 2 yellow-relations
  let total-yellow-yellow item 3 yellow-relations

  ; Definit le total des relations que possede les differente couleurs
  let total-friends-red total-red-red + total-red-blue + total-red-green + total-red-yellow
  if total-friends-red = 0 [ set total-friends-red 1]
  let total-friends-blue total-blue-red + total-blue-blue + total-blue-green + total-blue-yellow
  if total-friends-blue = 0 [ set total-friends-blue 1]
  let total-friends-green total-green-red + total-green-blue + total-green-green + total-green-yellow
  if total-friends-green = 0 [ set total-friends-green 1]
  let total-friends-yellow total-yellow-red + total-yellow-blue + total-yellow-green + total-yellow-yellow
  if total-friends-yellow = 0 [ set total-friends-yellow 1]

  ; Calculer les pourcentages moyens pour les rouges
  let avg-red (total-red-red / total-friends-red) * 100
  let avg-blue (total-blue-red / total-friends-blue) * 100
  let avg-green (total-green-red / total-friends-green) * 100
  let avg-yellow (total-yellow-red / total-friends-yellow) * 100

   ; Calculer les pourcentages moyens pour les bleus
  let avg-red-blue (total-red-blue / total-friends-red) * 100
  let avg-blue-blue (total-blue-blue / total-friends-blue) * 100
  let avg-green-blue (total-green-blue / total-friends-green) * 100
  let avg-yellow-blue (total-yellow-blue / total-friends-yellow) * 100

   ; Calculer les pourcentages moyens les verts
  let avg-red-green (total-red-green / total-friends-red) * 100
  let avg-blue-green (total-blue-green / total-friends-blue) * 100
  let avg-green-green (total-green-green / total-friends-green) * 100
  let avg-yellow-green (total-yellow-green / total-friends-yellow) * 100

  ; Calculer les pourcentages moyens les jaunes
  let avg-red-yellow (total-red-yellow / total-friends-red) * 100
  let avg-blue-yellow (total-blue-yellow / total-friends-blue) * 100
  let avg-green-yellow (total-green-yellow / total-friends-green) * 100
  let avg-yellow-yellow (total-yellow-yellow / total-friends-yellow) * 100

  ; Afficher les pourcentages moyens
  pretty-print "rouges" avg-red avg-blue avg-green avg-yellow
  pretty-print "bleus" avg-red-blue avg-blue-blue avg-green-blue avg-yellow-blue
  pretty-print "verts" avg-red-green avg-blue-green avg-green-green avg-yellow-green
  pretty-print "jaunes" avg-red-yellow avg-blue-yellow avg-green-yellow avg-yellow-yellow
end

; Affiche un pop-up pour connaitres les relations des differents opinions
to pretty-print [cur-color avg-r avg-b avg-g avg-y]
   user-message (word "Les " cur-color " ont en moyenne: " avg-r "% d'amis rouges - " avg-b "% d'amis bleus - " avg-g "% d'amis verts - " avg-y "% d'amis jaunes.")
end
@#$#@#$#@
GRAPHICS-WINDOW
375
10
812
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
0
10
64
43
Setup
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

BUTTON
65
10
128
43
Go
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

SLIDER
0
73
250
106
num-agents
num-agents
4
1000
80.0
2
1
user
HORIZONTAL

SLIDER
0
187
175
220
friends-influence
friends-influence
0
1
0.98
0.01
1
NIL
HORIZONTAL

SLIDER
0
132
172
165
max-friend
max-friend
1
50
3.0
1
1
NIL
HORIZONTAL

SWITCH
119
337
230
370
show-id
show-id
1
1
-1000

PLOT
864
47
1326
359
population
turtles
ticks
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"
"Rouge" 1.0 0 -5298144 true "" ""
"Bleu" 1.0 0 -10649926 true "" ""
"Vert" 1.0 0 -12087248 true "" ""
"Jaune" 1.0 0 -1184463 true "" ""

CHOOSER
211
148
350
193
strategy
strategy
"Similarity" "Diversity" "Random"
0

SLIDER
88
295
260
328
movement-step
movement-step
0.1
2
0.5
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
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
