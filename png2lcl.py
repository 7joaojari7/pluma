import imageio.v2 as imageio
import sys
import os

# Load the image
img = imageio.imread(sys.argv[1])

THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
output_file = os.path.join(THIS_FOLDER, sys.argv[2])

# Get the size of the image
img_height, img_width, _ = img.shape

with open(output_file, "w") as file:
    #file.write('//%d\n' % img_width)
    #file.write('//%d\n' % img_height)
    # Iterate over the image
    for y in range(img_height):
        for x in range(img_width):
            # Get the RGB values of the current pixel
            r, g, b = img[y, x]

            # Check if the red component is above the threshold
            if r == 237 and g == 28 and b == 36:
                file.write('1')
            else:
                file.write('0')
        file.write('\n')
