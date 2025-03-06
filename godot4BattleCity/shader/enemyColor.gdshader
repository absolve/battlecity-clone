shader_type canvas_item ;


uniform bool ischange=false;
uniform vec4 oldColor1:source_color =vec4(0);
uniform vec4 oldColor2:source_color =vec4(0);
uniform vec4 oldColor3:source_color =vec4(0);

uniform vec4 newColor1:source_color =vec4(0);
uniform vec4 newColor2:source_color =vec4(0);
uniform vec4 newColor3:source_color =vec4(0);

bool colorMatch(vec4 c1, vec4 c2, float maxDiff) {
    return (
        abs(c1.r - c2.r) < maxDiff
        && abs(c1.g - c2.g) < maxDiff
        && abs(c1.b - c2.b) < maxDiff
    );
}

void fragment() {
	if(ischange){
		vec4 color = texture(TEXTURE, UV);
		float variance = 0.0001;
		if(color.a == 1.0&&colorMatch(color,oldColor1,variance)){
			color=newColor1;
		}else if(color.a == 1.0&&colorMatch(color,oldColor2,variance)){
			color=newColor2;
		}else if(color.a == 1.0&&colorMatch(color,oldColor3,variance)){
			color=newColor3;
		}
		COLOR=color;
	}else{
		COLOR=texture(TEXTURE, UV);
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
