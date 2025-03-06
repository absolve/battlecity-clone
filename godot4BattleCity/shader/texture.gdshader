shader_type canvas_item;

//每个方块是否显示 0不显示
uniform  vec4 block:source_color = vec4(0.1,0.1,0.1,0.1);

float color1(vec2 position){
	if(block.x==0.0){
		if(position.x<=0.5&&position.y<=0.5){
			return 0.;
		}
	}
	if(block.y==0.0){
		if(position.x>0.5&&position.y<=0.5){
			return 0.;
		}
	}
	if(block.z==0.0){
		if(position.x<=0.5&&position.y>0.5){
			return 0.;
		}
	}
	if(block.a==0.0){
		if(position.x>0.5&&position.y<1.&&position.y>0.5){
			return 0.;
		}
	}
	return 1.;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	COLOR=vec4(vec3(color.r,color.g,color.b),color1(UV));
}


