CREATE TYPE rgba_color AS (
	r smallint;
	g smallint;
	b smallint;
);

CREATE FUNCTION from_rgb(rgb integer) RETURNS rgb_color AS $$
DECLARE
	result RETURNS rgb_color;
BEGIN
	result := (r => (rgb >> 16) & 0xFF,
			   g => (rgb >> 8) & 0xFF,
			   b => rgb & 0xFF);
	RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION Interpolate(l rgb_color, r rgb_color) RETURNS rgb_color AS $$
DECLARE
	result rgb_color;
BEGIN
	result := (r => (l.r + r.r) / 2,
			   g => (l.g + r.g) / 2,
			   b => (l.b + r.b) / 2);
	RETURN result;
END;
$$ LANGUAGE plpgsql;
