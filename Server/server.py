#!/usr/bin/env python
import tornado.ioloop
import tornado.web
import tornado.websocket

from tornado.options import define, options, parse_command_line

import os
import json
import uuid

define("port", default=8888, help="run on the given port", type=int)    
    
clients = set()
metadatas = dict()

class DiscoveryClient():
    connection = None
    relations = set()

    def __init__(self, c):
        self.connection = c


class WebSocketHandler(tornado.websocket.WebSocketHandler):
    def open(self):
        clients.add(DiscoveryClient(self))
        return None

    def on_close(self):
        for client in clients:                
            if client.connection == self:
                clients.remove(client)
                break

    def on_message(self, msg):
        payload = json.loads(msg)

        # decompose json
        body = payload["body"]
        header = payload["header"]

        # handle `absence`
        if header["type"] == "absence":
            print "Recived `absence` message: %s" % (body["id"])
            for client in clients:
                if client.connection == self:
                    client.relations.remove(body["id"])

        # handle `presence`
        if header["type"] == "presence":
            print "Recived `presence` message: %s" % (body["id"])
            payload = json.dumps({"header": {"type": "metadata"}, "body": metadatas[body["id"]]})
            for client in clients:
                if client.connection == self:
                    client.relations.add(body["id"])

                    # send metadata user to client
                    client.connection.write_message(payload, binary=True)
            
        # handle `metadata`
        if header["type"] == "metadata":
            print "Recived `metadata` message: %s" % (body)
            metadatas[body["id"]] = body
            payload = json.dumps({"header": {"type": "metadata"}, "body": body})

            for client in clients:
                client.connection.ws_connection.write_message(payload, binary=True)




app = tornado.web.Application([
    (r'/chat', WebSocketHandler)
])

if __name__ == '__main__':
    parse_command_line()

    print "Listening on port %i" % (options.port)
    app.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()

