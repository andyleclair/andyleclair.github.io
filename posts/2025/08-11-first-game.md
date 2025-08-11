%{
  title: "First Game!",
  description: "My first steps with Bevy ECS",
  author: "Andy LeClair",
  tags: ["rust", "bevy"],
  related_listening: "https://www.youtube.com/watch?v=yLnkVKJoL-4",
}
---

Been a minute since I've had a new post here, and there's a good reason for that. On April 29th 2025, my wife and I welcomed our second child to the world! We are so glad to have you here, Jamie Valentine!

Shocking absolutely no-one, having two children has put a bit of a damper on my extracurricular programming. That said, I did find a little time here and there to put together my first "game."

Game in quotes there, because it's a zero-player game. I've built a clone of [Pong Wars](https://github.com/vnglst/pong-wars) using [Bevy ECS](https://bevy.org/). Check the code out [here](https://github.com/andyleclair/bevy_pong_wars)

Overall, it was a fun project! I enjoy writing Rust well enough, and working from the Bevy examples, I was able to put this working game together in pretty short order. 

I did find my Elixir-y propensity to make a bunch of little helper functions is not in the Rust-way, and that's fine. I was trying to refactor a few bits to not repeat myself, but it's actually fine I guess? Judging by the [recent Linus Rant™](https://lore.kernel.org/lkml/CAHk-=wjLCqUUWd8DzG+xsOn-yVL0Q=O35U9D6j6=2DUWX52ghQ@mail.gmail.com/) maybe DRY-ing everything isn't actually a benefit.

Specifically, I was trying to DRY up this code here:

```rust

fn check_for_light_collisions(
    mut commands: Commands,
    mut light_score: ResMut<LightScore>,
    mut dark_score: ResMut<DarkScore>,
    ball_query: Single<(&mut Velocity, &Transform), (With<Ball>, With<Light>, Without<Dark>)>,
    block_query: Query<(Entity, &Transform), (With<Block>, With<Dark>)>,
) {
    let (mut ball_velocity, ball_transform) = ball_query.into_inner();
    for (block_entity, block_transform) in block_query {
        if let Some(collision) = ball_collision(
            BoundingCircle::new(ball_transform.translation.truncate(), BALL_SIZE / 2.),
            Aabb2d::new(
                block_transform.translation.truncate(),
                block_transform.scale.truncate() / 2.,
            ),
        ) {
            // Despawn the dark block and spawn a light block in its' place
            commands.entity(block_entity).despawn();
            commands.spawn((
                Sprite {
                    color: LIGHT_COLOR,
                    ..default()
                },
                block_transform.clone(),
                Block,
                Light,
            ));

            // Update the score
            **light_score += 1;
            **dark_score -= 1;

            // Reflect the ball's velocity when it collides
            let mut reflect_x = false;
            let mut reflect_y = false;

            // Reflect only if the velocity is in the opposite direction of the collision
            // This prevents the ball from getting stuck inside the bar
            match collision {
                Collision::Left => reflect_x = ball_velocity.x > 0.0,
                Collision::Right => reflect_x = ball_velocity.x < 0.0,
                Collision::Top => reflect_y = ball_velocity.y < 0.0,
                Collision::Bottom => reflect_y = ball_velocity.y > 0.0,
            }

            // Reflect velocity on the x-axis if we hit something on the x-axis
            if reflect_x {
                ball_velocity.x = -ball_velocity.x;
            }

            // Reflect velocity on the y-axis if we hit something on the y-axis
            if reflect_y {
                ball_velocity.y = -ball_velocity.y;
            }
        }
    }
}

fn check_for_dark_collisions(
    mut commands: Commands,
    mut light_score: ResMut<LightScore>,
    mut dark_score: ResMut<DarkScore>,
    ball_query: Single<(&mut Velocity, &Transform), (With<Ball>, With<Dark>, Without<Light>)>,
    block_query: Query<(Entity, &Transform), (With<Block>, With<Light>)>,
) {
    let (mut ball_velocity, ball_transform) = ball_query.into_inner();
    for (block_entity, block_transform) in block_query {
        if let Some(collision) = ball_collision(
            BoundingCircle::new(ball_transform.translation.truncate(), BALL_SIZE / 2.),
            Aabb2d::new(
                block_transform.translation.truncate(),
                block_transform.scale.truncate() / 2.,
            ),
        ) {
            // Despawn the dark block and spawn a light block in its' place
            commands.entity(block_entity).despawn();
            commands.spawn((
                Sprite {
                    color: DARK_COLOR,
                    ..default()
                },
                block_transform.clone(),
                Block,
                Dark,
            ));

            // Update the score
            **dark_score += 1;
            **light_score -= 1;

            // Reflect the ball's velocity when it collides
            let mut reflect_x = false;
            let mut reflect_y = false;

            // Reflect only if the velocity is in the opposite direction of the collision
            // This prevents the ball from getting stuck inside the bar
            match collision {
                Collision::Left => reflect_x = ball_velocity.x > 0.0,
                Collision::Right => reflect_x = ball_velocity.x < 0.0,
                Collision::Top => reflect_y = ball_velocity.y < 0.0,
                Collision::Bottom => reflect_y = ball_velocity.y > 0.0,
            }

            // Reflect velocity on the x-axis if we hit something on the x-axis
            if reflect_x {
                ball_velocity.x = -ball_velocity.x;
            }

            // Reflect velocity on the y-axis if we hit something on the y-axis
            if reflect_y {
                ball_velocity.y = -ball_velocity.y;
            }
        }
    }
}
```

Really, the only difference here is which colors we're "selecting" in the `Query` and the opposite-color spawning. I ran into a bunch of issues trying to make a helper, though. My shittiness at Rust was showing for sure!

That all said, this was a fun project. The Bevy template was brand new when I was starting this, so I went with the "rawdogging it all in main.rs" strategy that many of the examples show. 

Next I may rebuild it using the template to see how the experience differs. I was interested in getting into some Zig, but this project was fun and maybe I just keep writing Rust!
