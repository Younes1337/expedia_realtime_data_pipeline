from confluent_kafka import Producer
import json
from opensky_api import OpenSkyApi

def flights_data():
    api = OpenSkyApi()
    return api.get_states()

def read_config():
    config = {}
    with open("client.properties") as fh:
        for line in fh:
            line = line.strip()
            if len(line) != 0 and line[0] != "#":
                parameter, value = line.strip().split('=', 1)
                config[parameter] = value.strip()
    return config

def produce(topic, config, data):
    producer = Producer(config)
    
    for state in data.states:
        # Create proper JSON value
        value = {
            "icao24": state.icao24,
            "callsign": state.callsign.strip() if state.callsign else "",
            "origin_country": state.origin_country,
            "time_position": state.time_position,
            "last_contact": state.last_contact,
            "longitude": state.longitude,
            "latitude": state.latitude,
            "baro_altitude": state.baro_altitude,
            "on_ground": state.on_ground,
            "velocity": state.velocity,
            "true_track": state.true_track,
            "vertical_rate": state.vertical_rate,
            "geo_altitude": state.geo_altitude,
            "squawk": str(state.squawk) if state.squawk else None,
            "spi": state.spi,
            "position_source": state.position_source,
            "category": state.category
        }
        
        # Send with fixed key "123" and proper JSON value
        producer.produce(
            topic=topic,
            key="123",  # Using fixed key as in your working test
            value=json.dumps(value)  # Proper JSON serialization
        )
        print(f"Produced message to {topic}: {state.callsign}")

    producer.flush()

def main():
    config = read_config()
    topic = "topic-name"  # Fixed typo in topic name
    data = flights_data()
    produce(topic, config, data)

if __name__ == "__main__":
    main()
