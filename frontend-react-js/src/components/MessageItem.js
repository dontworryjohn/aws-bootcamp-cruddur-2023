import './MessageItem.css';
import { Link } from "react-router-dom";
import { format_datetime, message_time_ago } from '../lib/DateTimeFormats';

export default function MessageItem(props) {

  const format_time_created_at = (value) => {
    // format: 2050-11-20 18:32:47 +0000
    const created = DateTime.fromISO(value)
    const now     = DateTime.now()
    const diff_mins = now.diff(created, 'minutes').toObject().minutes;
    const diff_hours = now.diff(created, 'hours').toObject().hours;

    if (diff_hours > 24.0){
      return created.toFormat("LLL L");
    } else if (diff_hours < 24.0 && diff_hours > 1.0) {
      return `${Math.floor(diff_hours)}h`;
    } else if (diff_hours < 1.0) {
      return `${Math.round(diff_mins)}m`;
    }
  };

  return (
    <div className='message_item'>
      <Link className='message_avatar' to={`/messages/@`+props.message.handle}></Link>
      <div className='message_content'>
        <div classsName='message_meta'>
          <div className='message_identity'>
            <div className='display_name'>{props.message.display_name}</div>
            <div className="handle">@{props.message.handle}</div>
          </div>{/* activity_identity */}
        </div>{/* message_meta */}
        <div className="message">{props.message.message}</div>
        <div className="created_at" title={format_datetime(props.message.created_at)}>
          <span className='ago'>{message_time_ago(props.message.created_at)}</span> 
        </div>{/* created_at */}
      </div>{/* message_content */}
    </div>
  );
}