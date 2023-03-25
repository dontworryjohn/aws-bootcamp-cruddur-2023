from datetime import datetime, timedelta, timezone
from opentelemetry import trace

from lib.db import db

tracer = trace.get_tracer("home-activities")

class HomeActivities:
  def run(cognito_user_id=None):
    # logger is disabled currently to save on spend
    # logger.info("home activities")
    
    # Implementation of traces and spans for HoneyComb
    with tracer.start_as_current_span("home-activities-mock-data"):
      span = trace.get_current_span()
      now = datetime.now(timezone.utc).astimezone()
      span.set_attribute("app.now", now.isoformat())
      
      sql = db.template('activities','home')
      results = db.query_array_json(sql)

      return results
      
      # if cognito_user_id != None:
      #   extra_crud = {
      #   'uuid': '248959df-3079-4947-b847-9e0892d1bab4',
      #   'handle':  'Darth Sidious',
      #   'message': 'Your feeble skills are no match for the power of the Dark Side.',
      #   'created_at': (now - timedelta(hours=1)).isoformat(),
      #   'expires_at': (now + timedelta(hours=12)).isoformat(),
      #   'likes': 0,
      #   'replies': []
      # }
      
      #   results.insert(0,extra_crud)
      
      # return results