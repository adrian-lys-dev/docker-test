# syntax=docker/dockerfile:1

##########################
# Stage 1 — Build & Test #
##########################
FROM --platform=$BUILDPLATFORM dhi.io/dotnet:10-sdk AS build

ARG TARGETARCH

COPY . /source
WORKDIR /source/src

RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages \
    dotnet publish -a ${TARGETARCH/amd64/x64} --use-current-runtime --self-contained false -o /app

RUN dotnet test /source/tests

#####################################
# Stage 2 — Development (local dev) #
#####################################
FROM dhi.io/dotnet:10-sdk AS development
COPY . /source
WORKDIR /source/src

CMD ["dotnet", "run", "--no-launch-profile"]

#####################################
# Stage 3 — Final (prod image)      #
#####################################
FROM dhi.io/aspnetcore:10 AS final
WORKDIR /app

COPY --from=build /app .

ENTRYPOINT ["dotnet", "myWebApp.dll"]