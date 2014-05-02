/*
    TE4 - T-Engine 4
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini

    No permission to copy or replicate in any ways, awesomium is not gpl so we cant link directly
*/

extern "C" {
#include "tSDL.h"
#include "tgl.h"
#include "web-external.h"
#include <stdio.h>
}

#include "web.h"
#include "web-internal.h"

#include <cef_app.h>
#include <cef_app.h>
#include <cef_client.h>
#include <cef_display_handler.h>
#include <cef_render_handler.h>
#include <cef_request_handler.h>
#include <cef_render_process_handler.h>
#include <vector>

static std::vector<WebEvent*> *iqueue = new std::vector<WebEvent*>;
static std::vector<WebEvent*> *oqueue = new std::vector<WebEvent*>;
static void *lock_iqueue = NULL;
static void *lock_oqueue = NULL;

void te4_web_init_utils() {
	if (!lock_iqueue) lock_iqueue = web_mutex_create();
	if (!lock_oqueue) lock_oqueue = web_mutex_create();
}

void push_order(WebEvent *event)
{
	if (!lock_iqueue) return;
	web_mutex_lock(lock_iqueue);
	iqueue->push_back(event);
	web_mutex_unlock(lock_iqueue);
}

WebEvent *pop_order()
{
	if (!lock_iqueue) return NULL;
	WebEvent *event = NULL;

	web_mutex_lock(lock_iqueue);
	if (!iqueue->empty()) {
		event = iqueue->back();
		iqueue->pop_back();
	}
	web_mutex_unlock(lock_iqueue);

	return event;
}

void push_event(WebEvent *event)
{
	if (!lock_oqueue) return;

//	fprintf(logfile, "[WEBCORE] <Event push %d\n", event->kind);
	web_mutex_lock(lock_oqueue);
	oqueue->push_back(event);
	web_mutex_unlock(lock_oqueue);
//	fprintf(logfile, "[WEBCORE] >Event push %d\n", event->kind);
}

WebEvent *pop_event()
{
	if (!lock_oqueue) return NULL;
	WebEvent *event = NULL;

//	fprintf(logfile, "[WEBCORE] <Event pop\n");
	web_mutex_lock(lock_oqueue);
	if (!oqueue->empty()) {
		event = oqueue->back();
		oqueue->pop_back();
	}
	web_mutex_unlock(lock_oqueue);
//	fprintf(logfile, "[WEBCORE] >Event pop\n");

	return event;
}

