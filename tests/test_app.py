import copy
import unittest
from unittest.mock import patch

from fastapi import HTTPException

import app


class FakeCollection:
    def __init__(self):
        self.documents = []

    def insert_one(self, document):
        document['_id'] = 'database-id'
        self.documents.append(copy.deepcopy(document))
        return type('Result', (), {'inserted_id': document['_id']})()

    def find(self, query, projection=None):
        docs = copy.deepcopy(self.documents)
        if projection and projection.get('_id') == 0:
            for doc in docs:
                doc.pop('_id', None)
        return docs


class FakeDatabase:
    def __init__(self, available=True):
        self.items = FakeCollection()
        self.available = available

    def command(self, command):
        if not self.available:
            raise ConnectionError('database unavailable')
        return {'ok': 1}


class AppTests(unittest.IsolatedAsyncioTestCase):
    async def test_created_item_id_is_returned_in_list(self):
        database = FakeDatabase()
        db = type('Connection', (), {'database': database})()
        with patch.object(app, 'db', db):
            created = await app.create_item(app.ItemCreate(name='example'))
            items = await app.get_items()
        self.assertEqual(items[0]['id'], created.id)

    async def test_unavailable_database_fails_health_check(self):
        db = type('Connection', (), {'database': FakeDatabase(False)})()
        with patch.object(app, 'db', db):
            with self.assertRaises(HTTPException) as error:
                await app.health_check()
        self.assertEqual(error.exception.status_code, 503)

    async def test_health_check_without_database_uses_demo_mode(self):
        with patch.object(app, 'db', None):
            response = await app.health_check()
        self.assertEqual(response.status, 'healthy')

    async def test_health_check_with_available_database(self):
        db = type('Connection', (), {'database': FakeDatabase()})()
        with patch.object(app, 'db', db):
            response = await app.health_check()
        self.assertEqual(response.status, 'healthy')
