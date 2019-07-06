# 1.0.0

- `ImageSource` is now a class instead of a struct. Originally I used a struct to get the best performance possible. However the performance penalty for using an extra class is very small and image sources use reference semantics because they can be updated as they are downloaded. This should make the interface cleaner and easier to reason about.
- `ImageSource` properties for both the image and individual images are no longer optional.