CREATE TYPE vector2i AS (
    x INT,
    y INT
);

CREATE OR REPLACE FUNCTION left(rect rect_t) RETURNS INT AS $$
BEGIN
    RETURN rect.x;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION right(rect rect_t) RETURNS INT AS $$
BEGIN
    RETURN rect.x + rect.width - 1;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION top(rect rect_t) RETURNS INT AS $$
BEGIN
    RETURN rect.y;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION bottom(rect rect_t) RETURNS INT AS $$
BEGIN
    RETURN rect.y + rect.height - 1;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION left(rect rect_t, newLeft INT) RETURNS INT AS $$
BEGIN
    rect.width := rect.x - newLeft + rect.width;
    rect.x := newLeft;
    RETURN rect.x;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION right(rect rect_t, newRight INT) RETURNS INT AS $$
BEGIN
    rect.width := newRight - rect.x + 1;
    RETURN rect.x + rect.width - 1;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION top(rect rect_t, newTop INT) RETURNS INT AS $$
BEGIN
    rect.height := rect.y - newTop + rect.height;
    rect.y := newTop;
    RETURN rect.y;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION bottom(rect rect_t, newBottom INT) RETURNS INT AS $$
BEGIN
    rect.height := newBottom - rect.y + 1;
    RETURN rect.y + rect.height - 1;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION split(rect rect_t, cut rect_t) RETURNS rect_t[] AS $$
DECLARE
    clips rect_t[];
    victim rect_t := rect;
    clip rect_t;
BEGIN
    IF cut.left() > victim.left() AND cut.left() <= victim.right() THEN
        clip := ROW(victim.y, victim.x, victim.height, cut.left() - 1);
        victim.x := cut.left();
        clips := clips || clip;
    END IF;

    IF cut.top() > victim.top() AND cut.top() <= victim.bottom() THEN
        clip := ROW(victim.y, victim.x, cut.top() - 1, victim.width);
        victim.y := cut.top();
        clips := clips || clip;
    END IF;

    IF cut.right() >= victim.left() AND cut.right() < victim.right() THEN
        clip := ROW(victim.y, cut.right() + 1, victim.height, victim.right());
        victim.right := cut.right();
        clips := clips || clip;
    END IF;

    IF cut.bottom() >= victim.top() AND cut.bottom() < victim.bottom() THEN
        clip := ROW(cut.bottom() + 1, victim.x, victim.bottom(), victim.width);
        victim.bottom := cut.bottom();
        clips := clips || clip;
    END IF;

    RETURN clips;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION intersects(rect rect_t, other rect_t) RETURNS BOOLEAN AS $$
BEGIN
    RETURN rect.left() < other.right() AND rect.right() > other.left() AND rect.top() < other.bottom() AND rect.bottom() > other.top();
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION get_intersect(rect rect_t, cut rect_t) RETURNS rect_t AS $$
DECLARE
    victim rect_t := rect;
BEGIN
    IF cut.left() >= victim.left() AND cut.left() <= victim.right() THEN
        victim.x := cut.left();
    END IF;

    IF cut.top() >= victim.top() AND cut.top() <= victim.bottom() THEN
        victim.y := cut.top();
    END IF;

    IF cut.right() >= victim.left() AND cut.right() <= victim.right() THEN
        victim.right := cut.right();
    END IF;

    IF cut.bottom() >= victim.top() AND cut.bottom() <= victim.bottom() THEN
        victim.bottom := cut.bottom();
    END IF;

    RETURN victim;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION contains(rect rect_t, other rect_t) RETURNS BOOLEAN AS $$
BEGIN
    RETURN rect.left() < other.right() AND rect.left() <= other.left() AND rect.right() > other.left() AND rect.right() >= other.right() AND rect.top() < other.bottom() AND rect.top() <= other.top() AND rect.bottom() > other.top() AND rect.bottom() >= other.bottom();
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION contains(rect rect_t, other vector2i) RETURNS BOOLEAN AS $$
BEGIN
    RETURN other.x >= rect.x AND other.x < rect.right() AND other.y >= rect.y AND other.y < rect.bottom();
END;
$$ LANGUAGE plpgsql IMMUTABLE;
