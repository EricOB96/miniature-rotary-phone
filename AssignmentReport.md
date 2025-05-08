# Bird Feeding Simulation
# Eric O'Brien
#C21750829
( CA can be found in branch CA2 )

This is my Assignment where I made a Bird feeding simulation in VR. The idea came to when I was in Smithfield Square and I seen many signs around saying "Do not feed birds" .

I thought this was sad as living in the city nature is around us less and less, leaving birds and some trees are some of the only nature we get to see now of days. I took some pictures in the square of some birds and trees
and the sign as seen below.



![IMG_20250508_131749](https://github.com/user-attachments/assets/6596f397-4d8d-40bc-bae5-11a1e92ffb4c)


![IMG_20250508_131658](https://github.com/user-attachments/assets/4d00f0a3-195f-4a0d-873b-3b57c95bdfb6)


![IMG_20250508_131810](https://github.com/user-attachments/assets/7e7ea4f9-459f-44ef-9dcb-df2f5e5f8584)

![IMG_20250508_131852](https://github.com/user-attachments/assets/301f311f-283c-400a-b0a9-5a06323578fb)


# Main Features

![image](https://github.com/user-attachments/assets/e0e75901-b07d-4087-96bd-d1c46d15106d)


- Walk around in First person ( with snap rotate movement )
- Pickable food to throw for the birds
- Relaxing bird noises and music
- A flock of birds flying around looking for food
- A menu to turn off music and add or remove birds as the user pleases
- A some trees replicating from the photos in Smithfield.

I create a bird scene using CSG shapes and creating my own materials, and the same for the trees, food, and food holder. 

![Screenshot 2025-05-09 004847](https://github.com/user-attachments/assets/d7c1b686-4ad2-4bcd-94e6-596cc87f74fd)


I added these into into the main scene where the main enviornment, And adding the leader bird. The Leader bird uses follow path and seek. From there I added a Bird controller node and script where the bird will follow a path until it dectects the food when it touches the floor. When this happens it actives its other state seek where the target is thee food. Once collided with the food it will return to follow path. A new piece of food will spawn after a 2 second timer in the food holder and the cycle repeats. AnAudioStreamPlayer3D was added with bird sunds so if the birds were closer it would be louder. Spine animator was moddified to adjust for the flapping of the wings.

![Screenshot 2025-05-09 005022](https://github.com/user-attachments/assets/6546cfc3-3485-463a-a13d-bba9ce7ef7d5)


For the Flock, a node a script is added which adds the flock bird scene to the users choice, using a global bird controller, the signals can be called from the menu where a user can add or remove the flock birds. There is a calculate posistion for V formation and in editor of godot with offests of the degrees of the V, Spacing, Height, how quickly they get into position. To follow the leader an offset pursue was used.

For the player character, movement and snap rotate was implemented. Hands, function pointer and picking up objects were used from XR-godot-tool kit.

# What did I learn?

I learned how boids works anlong with pathfollow, seek and offset pursue. I learned how to make basic models with CSG shapes using, union intersect and subtraction and how to make scenes work together.

I also tried a different approach from being from the country side seeing nature in all its glory and have a different idea of what nature is like for me now living in the city for years, gaining a new appreciation for nature.


# Whats the Difference?

There is a difference between the real life deal and the simulation such as, it is quite hard to get realistic bird flight patterns and the models could look more realistic, plus there is no beating actually getting outside and feeding the birds in fresh air and the sun. The aim for this was not to get it realistic but to give the same realxing feeling as being outside and throing some bird food for the birds to eat.

# Link to Demo


