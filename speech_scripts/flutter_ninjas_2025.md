# Flutter Path Animation Presentation Script

## FlutterNinjas2025

Hello everyone!
I'm excited to be here today.

## Let me ask you a question!

Before we start, let me ask you a simple question!

## How would you implement this? Part1

Take a look at this animation.
How would we create this drawing animation in Flutter?

## How would you implement this? Part2

This is part 2

## How would you implement this? Part3

And part 3
This is the flight route animation from here in Tokyo to the birthplace of Flutter, Google's headquarters

## Let's use path animation!

Let's use path animation!

## Exploring Flutter Path Animations

So I'll start this talk, "Exploring Flutter Path Animations".

## README

Let me introduce myself quickly. I'm Sugiy.
I work at DeNA, where I develop a Flutter sports live streaming app 'play-by-sports'.
I was originally an iOS developer, but now I work with Flutter.
This is my first time speaking at FlutterNinjas!
I'm really interested in iOS and Android platform-optimized UX in Flutter apps.
I want to talk about this at the next Flutter conference, FlutterKaigi.
Oh, and I'm building my new home starting next month!

## Implementation Steps

Now, let's dive into the main topic.
Here are the four main steps:

1. Prepare a Path for the shape
2. Display the Path  
3. Show the Path partially based on progress
4. Animate according to progress

Let's check each step.

## Detailed source code will be available on blog and GitHub later

All source code will be available on my blog and GitHub after this talk.
If you're interested, please check there.

## Step 1: Prepare a Path for the desired shape

First, we need to create the path data.
For simple paths, we can create them ourselves or use AI tools.
For complex shapes, I recommend creating SVG files and converting them to Flutter Path objects.

I often use Figma to create SVG files.
I also use web conversion tools.
Another option is to build a tool that extracts path data from SVG files.

One important thing: the SVG paths should not be outlined or closed.

## Custom conversion logic from SVG to Flutter Path

Here's how to convert SVG to Flutter Path:

1. Use the xml plugin to load SVG files and parse them
2. Extract path elements and get the d attribute with the path data  
3. Use the path_drawing plugin to convert the d attribute to Flutter Path objects
4. SVG file may have paths, so to support that, addPath to combine multiple Paths

Now we can convert a basic SVG file into a Flutter path.

## Original Path and generated Flutter Path

This is the original SVG image and the Flutter path generated from it.
It's very long but this is only a part of it, we can see the Flutter Path is properly generated.

## Step 2: Implement a Widget to display the Path

For step two, we display the path:

1. Prepare the Flutter Path object from Step 1
2. Draw the Path using canvas.drawPath in the CustomPainter
3. Set the CustomPainter to a CustomPaint widget

This is the foundation for making paths visible.

## Step 3: Make the Path display partially based on progress

To show only part of the path:

1. Get PathMetric from the Path using computeMetrics. PathMetric provides length and segment information.
2. Use PathMetric's extractPath to generate partial paths according to progress from 0.0 to 1.0
3. Combine those Paths using addPath
4. Draw the path with canvas.drawPath in CustomPainter

This lets us control how much of the path is visible.

## Step 4: Enable animation according to progress

Finally, to make it animate:

1. Prepare an AnimationController and progress value
2. About the animationController, I used useAnimationController in flutter_hooks package
3. Change the drawing range according to the progress value from 0.0 to 1.0
4. Execute forward or repeat method of the AnimationController
5. Then the Path is gradually drawn as the animation progresses

## This is the implementation approach!

That's the basic approach!
It's simple but very powerful.

## Let's see a demo of how it actually works and take a short break

Let's see a demo of how it actually works and take a short break

## Japan Symbol Quiz

I created a Japan Symbol Quiz game to demonstrate path animations.

# Recently Japan-\\\\(region).swift regional events are trending in the Swift community

Recently Japan-\(region).swift regional events are trending in the Swift community.
And I talked about the path animation of SwiftUI in several events and try!SwiftTokyo conference last month.

## Symbol quizzes from regional events I've conducted

These are quizzes I did in the past events.
The symbols displayed are related to each regions.
I implemented various types of animations.
Today's presentation is a challenge to see if these implementations I did in Swift can also be done in Flutter.

## Compare SwiftUI and Flutter animation

By the way, the left side shows SwiftUI animation, and the right side shows the Flutter animation I implemented for this presentation, both running as actual apps.
We can see that almost the same movements have been reproduced.

## Japan Symbol Quiz 1

So let's try Japan Symbol Quiz!
Watch as the Symbol related to Japan is drawn.
Can you guess what this Japanese symbol is?
If you know the answer, please raise your hand.

## Origami

The answer is origami!

Origami is the Japanese art of paper folding. It transforms a flat piece of paper into beautiful sculptures through folding techniques, without using cuts or glue.

This photo shows works created by my friends, each made from a single piece of paper with just folding, no cuts at all.
It might be even more difficult than developing Flutter apps! (laughs)
Like Flutter, origami is very deep and creative play and art form.
I encourage you all to try it!

## Symbol quizzes from regional events I've conducted

Next, let's update this implementation and check how to implement an animation where the path moves forward with a fixed length, as shown in the bottom right.

## Animation with fixed Path length

For fixed-length path animation, we need a different approach.
First, we calculate the total path length and determine what portion should be visible based on progress.
Then we loop through each path segment, checking if it falls within our display range.
We only add the segments that are currently visible, creating a smooth moving effect.

## Code for fixed length Path animation

This code creates an animation where a fixed-length path moves forward by checking each path segment and only drawing the parts within the current range.

## It works like this!

By implementing it, we can achieve animations like this.

## Symbol quizzes from regional events I've conducted

Next, let's check if we can create text writing animations like the one shown in the bottom left in Flutter.
Path animation isn't just for symbols.
We can also animate text.

## Displaying alphabet with animation

Here I'm showing the alphabet being drawn.
This uses iOS System Font
This font is outlined, so it will be executed as a surrounding animation.
Then if we prepare not-outlined custom font, it means SinglePath Font for path animations, we can implement such a drawing animation.

## Text drawing animation

For text animation, the process is more complex:

1. Load single-path font and parse text using text_to_path_maker plugin
2. Extract each character's glyph path and measure their bounds
3. Transform Glyph paths to pixel space with Y-axis inversion and baseline adjustment
4. Place the glyphs horizontally with letter spacing
5. Scale the combined path and center it

## Let's check how it works!

Let's see this with another quiz.

## Japan Symbol Quiz 2

Here's another quiz.

A Japan-related symbol will be displayed gradually with text animation.
If you know the answer, please let me know.

## Toyosu Market

The answer is Toyosu Market!
This is Tokyo's famous wholesale fish and vegetable market.
It's one of the largest markets in the world and a very important symbol of Tokyo's food culture.
Toyosu market is very near from here, and we can get there within 5 minutes by car.
If we have the opportunity, please go and check it out!

## That wraps up the Swift implementation I did!

That wraps up the Swift implementation I did!

## I forgot about this implementation!

Oh wait, I almost forgot to show this flight route animation!
This is another great example of path animations.

## Content move animation along a Path

We can also move content along a path, not just draw the path itself.
We pass the widget we want to animate, then use getTangentForOffset to get the coordinates along the path.
As the animation progresses, we position the content at these changing coordinates.
This creates a smooth movement animation where any widget can follow the path.
We can also adjust rotation and fine-tune positioning with offsets if needed.

## We can also do this

And here's another example showing icon movement along a path.
You probably won't get this as a requirement, but as long as we have a Path, we can move any Widget along it!

## Icon Move Tab Sample

By utilizing this approach, we might be able to apply it to implement animations like icons moving to tabs as well.

## Wrap up

Let me wrap up what we covered today:

1. I explained how to animate Flutter Paths using a four-step approach
2. This is a simple topic, but has many applications in real apps
3. We played the Japan Symbol Quiz to guess Japanese symbols. Did we have fun?
4. There are other quizzes available too. If you want to try them, please catch me after this session.

## You can download this slide app from TestFlight

This slide is iOS application with add-to-app, so if you have iPhone or iPad, you can download this slide application from TestFlight.

## Thank you for listening!

That's all!
Thank you for listening!
