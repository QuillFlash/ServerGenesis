FROM debian
LABEL authors="TheAestheticFur"
RUN apt-get update && apt-get -y upgrades
ADD inner_setup.sh /inner_setup.sh
RUN chmod +x /inner_setup.sh
# Help: ChatGPT
ENTRYPOINT ["/inner_setup.sh"]