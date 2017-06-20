/*
	TE4 - T-Engine 4
	Copyright (C) 2009 - 2017 Nicolas Casalini

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Nicolas Casalini "DarkGod"
	darkgod@te4.org
*/

#include "renderer-moderngl/View.hpp"
#include <stack>

extern "C"{
#include "main.h"
}

static stack<View*> views_stack;

View::View() {
	from_screen_size = true;
	setOrthoView(screen->w / screen_zoom, screen->h / screen_zoom);
}

View::View(int w, int h) {
	setOrthoView(w, h);
}

View::~View() {
	if (in_use) use(false);
	if (camera_lua_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, camera_lua_ref);
	if (origin_lua_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, origin_lua_ref);
}

void View::setOrthoView(int w, int h) {
	mode = ViewMode::ORTHO;
	view = glm::ortho(0.f, (float)w, (float)h, 0.f, -1001.f, 1001.f);
	printf("[RendererGL] View set %dx%d\n", w, h);
}

void View::setProjectView(
	float fov_angle, int w, int h, float near_clip, float far_clip,
	DisplayObject *camera, int camera_ref, DisplayObject *origin, int origin_ref
) {
	if (camera_lua_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, camera_lua_ref);
	if (origin_lua_ref != LUA_NOREF) luaL_unref(L, LUA_REGISTRYINDEX, origin_lua_ref);

	mode = ViewMode::PROJECT;
	view = glm::perspective(
		fov_angle,         // The horizontal Field of View, in degrees : the amount of "zoom". Think "camera lens". Usually between 90° (extra wide) and 30° (quite zoomed in)
		(float)w / (float)h, // Aspect Ratio. Depends on the size of your window. Notice that 4/3 == 800/600 == 1280/960, sounds familiar ?
		near_clip,        // Near clipping plane. Keep as big as possible, or you'll get precision issues.
		far_clip       // Far clipping plane. Keep as little as possible.
	);
	camera_lua_ref = camera_ref;
	origin_lua_ref = origin_ref;
	camera_do = camera;
	origin_do = origin;
}

void View::onScreenResize(int w, int h) {
	if (!from_screen_size) return;
	printf("View resizing to screen size\n");

	switch (mode) {
		case ViewMode::ORTHO:
			setOrthoView(w / screen_zoom, h / screen_zoom);
			break;
		default:
			break;
	}
}

void View::use(bool v) {
	in_use = v;
	if (v) {
		views_stack.push(this);
	} else {
		if (views_stack.top() != this) {
			printf("[GL STATE] ERROR VIEW POPED IS NOT THIS\n");
		}
		views_stack.pop();
	}
}

mat4 View::get() {
	if (mode == ViewMode::ORTHO) return view;

	if (camera_do->isChanged() || origin_do->isChanged()) {
		camera_do->changed = false;
		origin_do->changed = false;
		glm::vec4 camera_point = glm::vec4(0, 0, 0, 1);
		glm::vec4 origin_point = glm::vec4(0, 0, 0, 1);

		recomputematrix camm = camera_do->computeParentCompositeMatrix(NULL, {camera_do->model, glm::vec4(1, 1, 1, 1), true});
		recomputematrix orim = origin_do->computeParentCompositeMatrix(NULL, {origin_do->model, glm::vec4(1, 1, 1, 1), true});
		camera_point = camm.model * camera_point;
		origin_point = orim.model * origin_point;

		printf("View:recomputing camera %f x %f x %f, origin %f x %f x %f\n", camera_point.x, camera_point.y, camera_point.z, origin_point.x, origin_point.y, origin_point.z);

		cam = glm::lookAt(
			glm::vec3(camera_point),
			glm::vec3(origin_point),
			glm::vec3(0, -1, 0)
		);
	}

	return view * cam;
}

// Make a default screensize orthogonal view, use it and stack it, never removing it so we have a default
void View::initFirst() {
	View *v = new View();
	v->use(true);
}

View* View::getCurrent() {
	if (views_stack.empty()) View::initFirst();
	return views_stack.top();
}