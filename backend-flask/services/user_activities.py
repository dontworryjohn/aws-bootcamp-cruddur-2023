#from datetime import datetime, timedelta, timezone
#from aws_xray_sdk.core import xray_recorder
from lib.db import db
class UserActivities:
  def run(user_handle):
    #try:
    model = {
      'errors': None,
      'data': None
    }

      #now = datetime.now(timezone.utc).astimezone()
      
    if user_handle == None or len(user_handle) < 1:
      model['errors'] = ['blank_user_handle']
    else:
      sql = db.template('users','show')
      results = db.query_object_json(sql,{'handle': user_handle})
      return results
      model['data'] = results


# subsegments xray
      #subsegment = xray_recorder.begin_subsegment('mock-data')
      # xray ---
      #dict = {
      #  "now": now.isoformat(),
      #  "results-size": len(model['data'])
      #}
      #subsegment.put_metadata('key', dict, 'namespace')
      #xray_recorder.end_subsegment()
    #finally:  
      # Close the segment
      #xray_recorder.end_subsegment()
     # return model