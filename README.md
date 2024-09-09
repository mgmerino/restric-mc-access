# Restrict access to Minecraft Server during certain hours.

This bash script is used to ban ALL users connected to a Minecraft server at a given time. It could be useful for parents who want to restrict their children's access to the server during school hours or at night.

The script assumes a docker based installation, rcon-cli installed and enabled in order to run the ban/unban command. The script is executed by a cron job. Jq is used to parse the json file containing the banned users.

The script will ban ALL connected users starting at certain hour. All banned users listed in allowed-players.txt will be unbanned at a later time. You can configure the script to suit your needs using a crontab entry.

## Wait, what!? A bash script to ban users from a Minecraft server?

Are you serious? Yes, I am. I have a Minecraft server running for my kids and I want to restrict their access to the server during school hours and at night. I could have used a plugin to do that, but I wanted to learn more about the Minecraft server and how to interact with it using bash scripts.

And of course, I learned how to test bash scripts using BATS.

## Requirements

- Minecraft Server (for example https://github.com/itzg/docker-minecraft-server)
- rcon-cli
- bash
- jq

### TODO

- [ ] Add more tests
- [ ] Add more documentation
- [x] Add a CI/CD pipeline

## Usage

Fill in the allowed-players.txt file with the list of players you want to unban automatically always on the server. One player per line. This will ensure that the script will unban those whitelisted players and not all who were banned (from banned-players.json file).

Create a crontab entry to run the script to suit your needs. In my case, I execute the script at 23:00 to ban the users and at 12:00 to unban the users.

```bash
0 23 * * * /home/mcadmin/mc-config/goto-bed.sh
0 12 * * * /home/mcadmin/mc-config/goto-bed.sh
```


### Testing

Tests are written used BATS. To run the tests, install bats and run the following command:

```bash
bats test/goto-bed.bats
```

### Contributing

If you have any suggestions or improvements, please open an issue or a pull request.


### License

MIT


