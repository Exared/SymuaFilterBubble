# BubbleFilter NetLogo

This project uses the NetLogo tool to simulate the emergence of filter bubbles in order to address the following issues:

How do these bubbles appear?
What phenomena diminish/amplify them?

![Image]([chemin/vers/image.png](https://github.com/Exared/SymuaFilterBubble/blob/main/Images/simulation.gif))

## Table des matières
- [Aperçu](#aperçu)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Contributors](#contributors)
- [Annotation](#annotation)

## Aperçu
We have created a social network model inspired by Facebook. We have utilized certain features of Facebook, such as the significance of friends in the news feed. It is primarily friends who provide the content on our news page and thus exert influence on us (unlike TikTok, for example, where personalization is mainly based on the most viewed videos).

Here is a detailed presentation of our model:

-   Environment:
    -   Representation: NetLogo's basic environment (black square) without any particular modifications representing the social network. The aim here is to maintain the freedom of "movement" within a social network.
    -   Parameters:
        -   Friend influence: Intensity of influence that friends have on an individual.
        -   Friend recommendation algorithm: Strategy for recommending friends.
-   Agents:
    -   Representation:
        -   Internet users (small figurines). Their colors represent their dominant opinion.
        -   Friendship links between internet users are represented by white lines.
    -   Parameters:
        -   Number of internet users (num-agents)
        -   Maximum number of friends allowed per internet user (max-friend)
        -   Agent's opinions, which is a list of 4 values between 0 and 1 (belief). Therefore, there are 4 possible opinions, with a value of 0 representing complete disbelief and 1 representing strong belief.
        -   Agent's ID (Id)
    -   Behaviors:
        -   Internet users move towards their friends.
        -   The opinions of an internet user are updated based on the opinions of their friends.


## Installation
Just need to install NetLogo.

## Utilisation
Play with the parameters, click on setup
Then click on go

![Image]([chemin/vers/image.png](https://github.com/Exared/SymuaFilterBubble/blob/main/Images/setup.png))

## Contributors
-   Theo Tinti
-   Julian Gil
-   Timothee Vattier
-   Antoine Feret

## Annotation

The presentation and the commentaries in the code are in french.

