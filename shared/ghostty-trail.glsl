void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;
  vec4 text = texture(iChannel0, uv);

  vec2 current_pos = vec2(iCurrentCursor.x, iCurrentCursor.y);
  vec2 previous_pos = vec2(iPreviousCursor.x, iPreviousCursor.y);

  vec2 cell_center_offset = vec2(iCurrentCursor.z * 0.5, -iCurrentCursor.w * 0.5);

  current_pos += cell_center_offset;
  previous_pos += cell_center_offset;

  vec2 cursor_direction = previous_pos - current_pos;
  vec2 pixel_direction = fragCoord.xy - current_pos;

  vec4 cursorColor = vec4(0.96, 0.88, 0.86, 1.0); // #f5e0dc (Rosewater)
  if (length(cursor_direction) > (iCurrentCursor.w * 2)) {
    float len_sq = dot(cursor_direction, cursor_direction);
    float dotproduct = 0.0;

    if (len_sq > 0.0) {
      dotproduct = dot(pixel_direction, cursor_direction) / len_sq;
    }

    dotproduct = clamp(dotproduct, 0.0, 1.0);
    vec2 closest_point = mix(current_pos, previous_pos, dotproduct);
    float dist = distance(fragCoord.xy, closest_point);

    float trail_thickness = iCurrentCursor.w * 0.30;

    if (dist > trail_thickness) {
      fragColor = text;
    } else {
      if ((1 - dotproduct) - (6 * (iTime - iTimeCursorChange)) > 0) {
        fragColor = cursorColor;
      } else {
        fragColor = text;
      }
    }
  } else {
    fragColor = text;
  }
}
