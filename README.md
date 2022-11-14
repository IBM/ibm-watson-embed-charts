# ibm-watson-embed-charts

Helm charts for the IBM Watson Libraries for Embed products.

IBM Watson Libraries is designed to help lower the barrier for AI adoption by helping address the skills shortage and development costs that are required to build AI models from scratch.

## Documentation

Find out more about the IBM Watson Libraries for Embed products  by reading the [product documentation](https://www.ibm.com/docs/watson-libraries).

To learn more about embedding the products and working with the IBM sales team, visit the [Partner World page](https://www.ibm.com/partnerworld/program/embeddableai).

## License

The Helm charts are licensed under Apache 2.0.

The containers the chart deploys are licensed under separate product licenses.

Product licenses are included in the charts under the `licenses` directory.

To run the containers and deploy the helm charts, the licenses must be accepted by setting up an override yaml configuration with `license: true`.

## Federal Information Processing Standards (FIPS) compliance statement

This product is not FIPS 140-2 or 140-3 compliant. Clients can deploy and run on FIPS-enabled clusters, but the provided containers are not compliant with FIPS specifications.

## Hardware and Platform Support

The containers currently only supports running on x86 machines.

The containers has been verified to work on OpenShift 4.11, however it should run on any platform that supports containers.
