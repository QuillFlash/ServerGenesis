FROM debian
RUN apt-get update
ADD inner_setup.sh /inner_setup.sh
RUN chmod +x /inner_setup.sh
# Help: ChatGPT
ENTRYPOINT ["/inner_setup.sh"]