import './ProfileHeading.css';
import EditProfileButton from '../components/EditProfileButton';


export default function ProfileHeading(props) {
    return (
        <div className='activity_feed_heading profile_heading'>
            <div className='title'>{props.profile.display_name}</div>
            <div className="cruds_count">{props.profile.cruds_count} Cruds</div>
        
            <div className="avatar">
                <img src="https://assets.johnbuen.co.uk/avatars/data.jpg"></img>
            </div>
            <div className="display_name">{props.display_name}</div>
            <div className="handle">@{props.handle}</div>

            <EditProfileButton />
        </div>
    );
}