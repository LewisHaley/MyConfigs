import re

from PIL import Image, ImageDraw


def invert_colour(col):
    """Invert hex colour
    >>> invert_colour('#129AEF')
    '#ED6510'
    """
    assert col.startswith('#')
    assert len(col) == 7

    vals = [ str(d) for d in range(10) ] + [ 'A', 'B', 'C', 'D', 'E', 'F' ]

    inverses = {'#': '#'}
    for k, v in zip(vals, reversed(vals)):
        inverses[k] = v

    return ''.join([inverses[c] for c in col.upper()])


def main():
    TERMINATOR_CONFIG = 'terminator_config'
    WIDTH = 50

    palette = None
    with open(TERMINATOR_CONFIG, 'r') as f_in:
        for line in f_in.readlines():
            if 'palette' in line:
                palette = re.search(
                    r'palette = "(?P<p>.*)"', line.strip()
                    ).groupdict()['p'].split(':')
                break

    im = Image.new("RGB", (WIDTH * len(palette), 50))
    draw = ImageDraw.Draw(im)

    x = 0
    for i, colour in enumerate(palette):
        draw.rectangle((x, 0, x + WIDTH, 50), fill=colour)
        draw.text((x + 10, 10), str(i), fill=invert_colour(colour))
        draw.text((x + 5, 25), colour, fill=invert_colour(colour))
        x += WIDTH


    im.show()


if __name__ == '__main__':
    main()
